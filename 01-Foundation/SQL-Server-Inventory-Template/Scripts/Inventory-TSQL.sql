-- =============================================
-- Script: Inventory-TSQL.sql
-- Description: Collects core instance and database metadata for SQL Server inventory.
-- Supported Versions: SQL Server 2016+
-- Author: DBA Operations Library Community
-- =============================================

SET NOCOUNT ON;

-- 1. Instance Metadata
SELECT 
    SERVERPROPERTY('MachineName') AS HostName,
    SERVERPROPERTY('ServerName') AS InstanceName,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
    SERVERPROPERTY('ProductLevel') AS PatchLevel, -- SP/CU
    SERVERPROPERTY('Edition') AS Edition,
    SERVERPROPERTY('IsClustered') AS IsClustered,
    SERVERPROPERTY('IsHadrEnabled') AS IsAlwaysOnEnabled;

-- 2. Database Metadata
SELECT 
    db.name AS DatabaseName,
    db.state_desc AS State,
    db.recovery_model_desc AS RecoveryModel,
    db.compatibility_level AS CompatibilityLevel,
    (SUM(mf.size) * 8) / 1024 AS SizeMB
FROM sys.databases db
JOIN sys.master_files mf ON db.database_id = mf.database_id
GROUP BY db.name, db.state_desc, db.recovery_model_desc, db.compatibility_level;
