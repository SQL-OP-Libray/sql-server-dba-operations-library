-- =============================================
-- Script: Inventory-TSQL.sql
-- Description: Collects core instance, database, configuration, and backup metadata for SQL Server inventory.
-- Supported Versions: SQL Server 2016+
-- Author: DBA Operations Library Community (#SQLDBAOpsLib)
-- =============================================

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- ============================================================================
-- 1. INSTANCE & HOST METADATA
-- Purpose: Captures host-level hardware specs, operating system info, engine 
--          build/patch levels, and high-availability enablement settings.
-- ============================================================================
SELECT 
    CAST(SERVERPROPERTY('MachineName') AS VARCHAR(64)) AS HostName,
    CAST(SERVERPROPERTY('ServerName') AS VARCHAR(64)) AS InstanceName,
    CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(32)) AS ProductVersion,
    CAST(SERVERPROPERTY('ProductLevel') AS VARCHAR(32)) AS PatchLevel, -- RTM, SP, CU
    CAST(SERVERPROPERTY('Edition') AS VARCHAR(64)) AS Edition,
    CAST(SERVERPROPERTY('Collation') AS VARCHAR(64)) AS InstanceCollation,
    cpu_count AS LogicalCPUCount,
    CAST(ROUND(physical_memory_kb / 1024.0 / 1024.0, 2) AS DECIMAL(10,2)) AS HostRAM_GB,
    CAST(SERVERPROPERTY('IsClustered') AS BIT) AS IsClustered,
    CAST(SERVERPROPERTY('IsHadrEnabled') AS BIT) AS IsAlwaysOnEnabled,
    GETDATE() AS InventoryCollectedDate
FROM sys.dm_os_sys_info;

-- ============================================================================
-- 2. CORE INSTANCE CONFIGURATIONS
-- Purpose: Audits critical server-level settings (Memory thresholds, Parallelism, 
--          and Security features) to detect environment configuration drift.
-- ============================================================================
SELECT 
    CAST(SERVERPROPERTY('ServerName') AS VARCHAR(64)) AS InstanceName,
    name AS ConfigurationName,
    value AS ConfiguredValue,
    value_in_use AS ValueInUse
FROM sys.configurations
WHERE name IN (
    'max server memory (MB)',
    'min server memory (MB)',
    'cost threshold for parallelism',
    'max degree of parallelism',
    'clr enabled',
    'xp_cmdshell'
)
ORDER BY name;

-- ============================================================================
-- 3. DATABASE METADATA & STORAGE BREAKDOWN
-- Purpose: Catalogues database state, compatibility levels, encryption (TDE), 
--          storage allocation (Data vs Log), and flags unsafe options (Auto-Close/Shrink).
-- ============================================================================
SELECT 
    db.database_id AS DatabaseID,
    db.name AS DatabaseName,
    db.state_desc AS State,
    db.recovery_model_desc AS RecoveryModel,
    db.compatibility_level AS CompatibilityLevel,
    db.is_encrypted AS IsTDEEncrypted,
    db.is_auto_close_on AS IsAutoCloseEnabled,   -- Risk Flag: Should be FALSE in Prod
    db.is_auto_shrink_on AS IsAutoShrinkEnabled, -- Risk Flag: Should be FALSE in Prod
    CAST((SUM(mf.size) * 8.0) / 1024.0 AS DECIMAL(10,2)) AS TotalSizeMB,
    CAST((SUM(CASE WHEN mf.type = 0 THEN mf.size ELSE 0 END) * 8.0) / 1024.0 AS DECIMAL(10,2)) AS DataSizeMB,
    CAST((SUM(CASE WHEN mf.type = 1 THEN mf.size ELSE 0 END) * 8.0) / 1024.0 AS DECIMAL(10,2)) AS LogSizeMB
FROM sys.databases db
JOIN sys.master_files mf ON db.database_id = mf.database_id
GROUP BY 
    db.database_id, 
    db.name, 
    db.state_desc, 
    db.recovery_model_desc, 
    db.compatibility_level,
    db.is_encrypted,
    db.is_auto_close_on,
    db.is_auto_shrink_on
ORDER BY TotalSizeMB DESC;

-- ============================================================================
-- 4. BACKUP BASELINE & FRESHNESS CHECKS
-- Purpose: Inspects backup history in msdb to verify recovery point objectives 
--          (RPO) and immediately flags unbacked or stale databases.
-- ============================================================================
SELECT 
    db.name AS DatabaseName,
    db.recovery_model_desc AS RecoveryModel,
    MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) AS LastFullBackupDate,
    MAX(CASE WHEN b.type = 'I' THEN b.backup_finish_date END) AS LastDiffBackupDate,
    MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) AS LastLogBackupDate,
    CASE 
        WHEN MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) IS NULL THEN 'CRITICAL: No Full Backup Found'
        WHEN MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) < DATEADD(DAY, -7, GETDATE()) THEN 'HIGH: Full Backup > 7 Days Old'
        ELSE 'OK'
    END AS BackupRiskStatus
FROM sys.databases db
LEFT JOIN msdb.dbo.backupset b ON db.name = b.database_name
WHERE db.name <> 'tempdb'
GROUP BY db.name, db.recovery_model_desc
ORDER BY LastFullBackupDate ASC;
