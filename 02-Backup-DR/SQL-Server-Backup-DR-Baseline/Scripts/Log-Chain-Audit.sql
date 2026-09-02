-- ===============================================================================
-- Script:      Log-Chain-Audit.sql
-- Library:     SQL Server DBA Operations Library (#SQLDBAOpsLib-02)
-- Description: Audits database recovery models, backup timestamps, and flags 
--              broken transaction log chains and backup SLA violations.
-- Author:      Zadig & Open Source Community
-- ===============================================================================

SET NOCOUNT ON;

SELECT 
    d.name AS DatabaseName,
    d.recovery_model_desc AS RecoveryModel,
    d.state_desc AS DatabaseState,
    -- Backup Timestamps
    MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) AS LastFullBackup,
    DATEDIFF(HOUR, MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END), GETDATE()) AS HoursSinceLastFull,
    MAX(CASE WHEN b.type = 'I' THEN b.backup_finish_date END) AS LastDiffBackup,
    MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) AS LastLogBackup,
    DATEDIFF(MINUTE, MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END), GETDATE()) AS MinsSinceLastLog,
    -- SLA Compliance Audit Logic
    CASE 
        WHEN d.recovery_model_desc = 'FULL' 
             AND MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) IS NULL 
            THEN 'CRITICAL: No Log Backup (Chain Broken / T-Log Growth Risk)'
        WHEN d.recovery_model_desc = 'FULL' 
             AND DATEDIFF(MINUTE, MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END), GETDATE()) > 60 
            THEN 'WARNING: Log Backup SLA Exceeded (>60 Mins)'
        WHEN MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END) IS NULL 
            THEN 'CRITICAL: No Full Backup Found'
        WHEN DATEDIFF(DAY, MAX(CASE WHEN b.type = 'D' THEN b.backup_finish_date END), GETDATE()) > 7 
            THEN 'WARNING: Full Backup Stale (>7 Days)'
        ELSE 'OK / Compliant'
    END AS SLA_AuditStatus
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b 
    ON d.name = b.database_name
WHERE d.database_id > 4 -- Exclude system databases
  AND d.state_desc = 'ONLINE'
GROUP BY 
    d.name, 
    d.recovery_model_desc, 
    d.state_desc
ORDER BY 
    CASE 
        WHEN d.recovery_model_desc = 'FULL' AND MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END) IS NULL THEN 1
        WHEN DATEDIFF(MINUTE, MAX(CASE WHEN b.type = 'L' THEN b.backup_finish_date END), GETDATE()) > 60 THEN 2
        ELSE 3
    END, 
    DatabaseName;
