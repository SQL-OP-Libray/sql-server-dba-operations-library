-- =============================================
-- Script: Inventory-Checks.sql
-- Description: Automated Risk & Health Audit Suite to identify misconfigurations, 
--              missing backups, storage risks, and security vulnerabilities.
-- Supported Versions: SQL Server 2016+
-- Author: DBA Operations Library Community (#SQLDBAOpsLib)
-- =============================================

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- ============================================================================
-- SECTION 1: UNBACKED & STALE BACKUP AUDIT
-- Purpose: Exposes databases missing full backups within 7 days or transaction 
--          log backups within 4 hours (for databases in FULL recovery mode).
-- Risk Level: 🔴 CRITICAL
-- ============================================================================
SELECT 
    db.name AS DatabaseName,
    db.recovery_model_desc AS RecoveryModel,
    MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) AS LastFullBackup,
    MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) AS LastLogBackup,
    CASE 
        WHEN MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) IS NULL 
            THEN 'CRITICAL: No Full Backup Ever Taken'
        WHEN MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) < DATEADD(DAY, -7, GETDATE()) 
            THEN 'HIGH: Full Backup Stale (> 7 Days)'
        WHEN db.recovery_model_desc = 'FULL' 
             AND (MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) IS NULL 
                  OR MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) < DATEADD(HOUR, -4, GETDATE()))
            THEN 'HIGH: Transaction Log Backup Stale (> 4 Hours)'
        ELSE 'OK'
    END AS BackupRiskSeverity
FROM sys.databases db
LEFT JOIN msdb.dbo.backupset b ON db.name = b.database_name
WHERE db.name <> 'tempdb' 
  AND db.state_desc = 'ONLINE'
GROUP BY db.name, db.recovery_model_desc
HAVING 
    MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) IS NULL
    OR MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) < DATEADD(DAY, -7, GETDATE())
    OR (db.recovery_model_desc = 'FULL' 
        AND (MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) IS NULL 
             OR MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) < DATEADD(HOUR, -4, GETDATE())));

-- ============================================================================
-- SECTION 2: UNSAFE DATABASE AUTO-GROWTH AUDIT
-- Purpose: Identifies database files using percent-based growth (%) instead 
--          of explicit megabyte growth, which can cause unexpected disk spikes.
-- Risk Level: 🟡 MEDIUM
-- ============================================================================
SELECT 
    DB_NAME(mf.database_id) AS DatabaseName,
    mf.name AS LogicalFileName,
    mf.type_desc AS FileType,
    mf.growth AS GrowthSettingValue,
    CASE WHEN mf.is_percent_growth = 1 THEN 'PERCENT' ELSE 'MEGABYTES' END AS GrowthType,
    'WARNING: Convert Percent Growth to Explicit MB Growth' AS RemediationAction
FROM sys.master_files mf
WHERE mf.is_percent_growth = 1 
  AND mf.database_id > 4 -- Exclude system databases
ORDER BY DatabaseName;

-- ============================================================================
-- SECTION 3: MEMORY & THREAD CONFIGURATION AUDIT
-- Purpose: Flags instances running with default max memory settings (2 TB) 
--          or unconfigured parallelism settings, risking OS memory starvation.
-- Risk Level: 🟡 MEDIUM / 🔴 HIGH
-- ============================================================================
SELECT 
    name AS ConfigurationName,
    value_in_use AS CurrentValue,
    CASE 
        WHEN name = 'max server memory (MB)' AND CAST(value_in_use AS BIGINT) >= 2147483647 
            THEN 'CRITICAL: Max Server Memory set to default (unbounded memory allocation)'
        WHEN name = 'cost threshold for parallelism' AND CAST(value_in_use AS INT) = 5 
            THEN 'WARNING: Default Cost Threshold (5) may cause unnecessary query parallelization'
        ELSE 'OK'
    END AS ConfigurationRiskFlag
FROM sys.configurations
WHERE name IN ('max server memory (MB)', 'cost threshold for parallelism')
  AND (
      (name = 'max server memory (MB)' AND CAST(value_in_use AS BIGINT) >= 2147483647)
      OR (name = 'cost threshold for parallelism' AND CAST(value_in_use AS INT) = 5)
  );

-- ============================================================================
-- SECTION 4: SYSADMIN PRIVILEGE AUDIT
-- Purpose: Lists all logins holding elevated sysadmin privileges to satisfy 
--          least-privilege compliance (SOC 2, ISO 27001).
-- Risk Level: 🔒 SECURITY AUDIT
-- ============================================================================
SELECT 
    sp.name AS LoginName,
    sp.type_desc AS LoginType,
    sp.is_disabled AS IsDisabled,
    'AUDIT: Verify sysadmin assignment is strictly required' AS SecurityNote
FROM sys.server_role_members srm
JOIN sys.server_principals sp ON srm.member_principal_id = sp.principal_id
JOIN sys.server_principals role ON srm.role_principal_id = role.principal_id
WHERE role.name = 'sysadmin' 
  AND sp.name NOT LIKE 'NT SERVICE\%'
ORDER BY sp.name;
