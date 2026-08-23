-- =============================================
-- Script: Inventory-Checks.sql
-- Description: Identifies inventory anomalies, missing backups, and unsupported compatibility levels.
-- Author: DBA Operations Library Community
-- =============================================

SET NOCOUNT ON;

-- Flag Databases Missing Recent Full Backups (Last 7 Days)
SELECT 
    d.name AS DatabaseName,
    MAX(b.backup_finish_date) AS LastFullBackup
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b 
    ON d.name = b.database_name AND b.type = 'D'
WHERE d.name <> 'tempdb'
GROUP BY d.name
HAVING MAX(b.backup_finish_date) < DATEADD(dd, -7, GETDATE()) 
    OR MAX(b.backup_finish_date) IS NULL;
