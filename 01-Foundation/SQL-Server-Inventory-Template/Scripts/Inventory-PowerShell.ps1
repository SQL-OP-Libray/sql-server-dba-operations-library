<#
.SYNOPSIS
    Inventory-PowerShell.ps1 - Automated Multi-Instance SQL Server Inventory Collector
.DESCRIPTION
    Queries a list of SQL Server instances using Microsoft.Data.SqlClient (or dbatools/SqlServer module)
    to gather host, instance, and database metadata across your estate and export results to CSV.
.NOTES
    Project: SQL Server DBA Operations Library (#SQLDBAOpsLib)
    Manual:  01 - SQL Server Inventory Template (August 2026)
    Author:  DBA Operations Library Community
#>

[CmdletBinding()]
param(
    # Array of SQL Server instances to inventory (e.g., 'SQLPROD01', 'SQLPROD02\INSTANCE1')
    [Parameter(Mandatory = $false)]
    [string[]]$ServerList = @('localhost'),

    # Directory where inventory CSV export files will be written
    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = "C:\DBA\Inventory\Exports"
)

# Set error action preference to continue so one failing server does not stop the loop
$ErrorActionPreference = "Continue"

# Ensure output directory exists before proceeding
if (-not (Test-Path -Path $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

# Timestamp used for output file naming
$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$OutputFile = Join-Path -Path $OutputDirectory -ChildPath "SQL_Inventory_$TimeStamp.csv"

# Array to collect combined results from all servers
$InventoryResults = [System.Collections.Generic.List[PSObject]]::new()

# ============================================================================
# SECTION 1: SERVER LOOP & CONNECTION HANDLING
# Purpose: Iterates through each targeted instance, establishes a connection,
#          and handles connectivity timeouts gracefully without crashing.
# ============================================================================
foreach ($Server in $ServerList) {
    Write-Host "[+] Processing SQL Server Instance: $Server..." -ForegroundColor Cyan

    # Connection string utilizing Windows Integrated Security with a 10-second timeout
    $ConnectionString = "Server=$Server;Database=master;Integrated Security=True;TrustServerCertificate=True;Connection Timeout=10;"

    try {
        $Connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
        $Connection.Open()

        # ============================================================================
        # SECTION 2: INSTANCE METADATA EXTRACTION
        # Purpose: Executes DMV queries to extract OS, hardware, build version,
        #          and engine settings from the connected SQL Server instance.
        # ============================================================================
        $InstanceQuery = @"
        SELECT 
            CAST(SERVERPROPERTY('MachineName') AS VARCHAR(64)) AS HostName,
            CAST(SERVERPROPERTY('ServerName') AS VARCHAR(64)) AS InstanceName,
            CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(32)) AS ProductVersion,
            CAST(SERVERPROPERTY('Edition') AS VARCHAR(64)) AS Edition,
            CAST(SERVERPROPERTY('IsHadrEnabled') AS BIT) AS IsAlwaysOnEnabled,
            cpu_count AS LogicalCPUCount,
            CAST(ROUND(physical_memory_kb / 1024.0 / 1024.0, 2) AS DECIMAL(10,2)) AS HostRAM_GB
        FROM sys.dm_os_sys_info;
"@

        $Command = $Connection.CreateCommand()
        $Command.CommandText = $InstanceQuery
        $Adapter = New-Object System.Data.SqlClient.SqlDataAdapter($Command)
        $Dataset = New-Object System.Data.DataSet
        $Adapter.Fill($Dataset) | Out-Null

        $Row = $Dataset.Tables[0].Rows[0]

        # ============================================================================
        # SECTION 3: DATA OBJECT CONSTRUCT & AGGREGATION
        # Purpose: Maps raw SQL query results into structured Custom PowerShell 
        #          Objects for CSV export and downstream integration.
        # ============================================================================
        $ServerInfo = [PSCustomObject]@{
            HostName          = $Row.HostName
            InstanceName      = $Row.InstanceName
            ProductVersion    = $Row.ProductVersion
            Edition           = $Row.Edition
            IsAlwaysOnEnabled = $Row.IsAlwaysOnEnabled
            LogicalCPUCount   = $Row.LogicalCPUCount
            HostRAM_GB        = $Row.HostRAM_GB
            Status            = "Online"
            CollectedDate     = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }

        $InventoryResults.Add($ServerInfo)
        $Connection.Close()

    } catch {
        # Catch connection failures, permission denials, or offline servers
        Write-Warning "[-] Failed to connect to $Server. Error: $_"
        
        # Log offline/unreachable servers to maintain complete inventory visibility
        $FailedServerInfo = [PSCustomObject]@{
            HostName          = $Server
            InstanceName      = $Server
            ProductVersion    = "N/A"
            Edition           = "N/A"
            IsAlwaysOnEnabled = $false
            LogicalCPUCount   = 0
            HostRAM_GB        = 0.00
            Status            = "OFFLINE / UNREACHABLE"
            CollectedDate     = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
        $InventoryResults.Add($FailedServerInfo)
    }
}

# ============================================================================
# SECTION 4: EXPORT & REPORT GENERATION
# Purpose: Flushes collected dataset to disk as a CSV file for auditing.
# ============================================================================
$InventoryResults | Export-Csv -Path $OutputFile -NoTypeInformation
Write-Host "`n[✓] Inventory Collection Complete. Results saved to: $OutputFile" -ForegroundColor Green
