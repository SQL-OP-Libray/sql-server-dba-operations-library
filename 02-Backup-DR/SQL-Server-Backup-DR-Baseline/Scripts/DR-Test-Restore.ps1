<#
.SYNOPSIS
    Automated Backup Verification & Disaster Recovery Test Restore Routine.
.DESCRIPTION
    Script:      DR-Test-Restore.ps1
    Library:     SQL Server DBA Operations Library (#SQLDBAOpsLib-02)
    Author:      Zadig & Open Source Community

    This script leverages dbatools to automate disaster recovery testing by:
      1. Identifying the latest backup set for target database(s).
      2. Performing a test restore to a staging/DR SQL Server instance.
      3. Running DBCC CHECKDB against the restored database to verify physical/logical integrity.
      4. Capturing execution timing and integrity test pass/fail results.
      5. Dropping the staging database to keep the environment clean.
.PARAMETER SqlInstance
    The target staging or DR SQL Server instance where test restorations will occur.
.PARAMETER BackupPath
    UNC path or directory containing database backups (.bak / .trn).
.PARAMETER DatabaseName
    Name of the source database to test restore.
.PARAMETER StagingPrefix
    Prefix appended to restored staging databases (Default: 'DR_Test_').
.EXAMPLE
    .\DR-Test-Restore.ps1 -SqlInstance "SQLSTAGE01" -BackupPath "\\NAS01\Backups\PRODDB" -DatabaseName "PRODDB"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SqlInstance,

    [Parameter(Mandatory = $true)]
    [string]$BackupPath,

    [Parameter(Mandatory = $true)]
    [string]$DatabaseName,

    [Parameter(Mandatory = $false)]
    [string]$StagingPrefix = "DR_Test_"
)

# Ensure dbatools module is installed and loaded
if (-not (Get-Module -Name dbatools -ListAvailable)) {
    Write-Error "dbatools module is required. Install it using: Install-Module dbatools -Scope CurrentUser"
    exit 1
}

Import-Module dbatools -DisableNameChecking

$StagingDbName = "$StagingPrefix$DatabaseName"
$StartTime = Get-Date

Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "Starting DR Restore Verification for Database: [$DatabaseName]" -ForegroundColor Cyan
Write-Host "Staging Target Instance: [$SqlInstance]" -ForegroundColor Cyan
Write-Host "Staging Database Name:   [$StagingDbName]" -ForegroundColor Cyan
Write-Host "Timestamp:               [$StartTime]" -ForegroundColor Cyan
Write-Host "=========================================================================" -ForegroundColor Cyan

try {
    # Step 1: Scan and test restore using dbatools Test-DbaLastBackup
    Write-Host "`n[1/3] Initiating Test Restore & Database Integrity Check..." -ForegroundColor Yellow
    
    $TestResult = Test-DbaLastBackup -SqlInstance $SqlInstance `
                                      -Path $BackupPath `
                                      -DatabaseName $DatabaseName `
                                      -DestinationAutoName `$StagingDbName `
                                      -VerifyOnly:$false `
                                      -Checkdb

    $EndTime = Get-Date
    $DurationMinutes = [math]::Round(($EndTime - $StartTime).TotalMinutes, 2)

    # Step 2: Evaluate Results
    Write-Host "`n[2/3] Verification Results Summary:" -ForegroundColor Yellow
    
    if ($TestResult.RestoreResult -eq "Success" -and $TestResult.CheckDbResult -eq "Success") {
        Write-Host "  -> Restore Status:   SUCCESS" -ForegroundColor Green
        Write-Host "  -> CHECKDB Status:   PASSED (0 Integrity Errors Detected)" -ForegroundColor Green
        Write-Host "  -> Total Duration:   $DurationMinutes Minutes" -ForegroundColor Green
        
        $Outcome = "PASSED"
    } else {
        Write-Host "  -> Restore Status:   $($TestResult.RestoreResult)" -ForegroundColor Red
        Write-Host "  -> CHECKDB Status:   $($TestResult.CheckDbResult)" -ForegroundColor Red
        Write-Host "  -> Total Duration:   $DurationMinutes Minutes" -ForegroundColor Red
        
        $Outcome = "FAILED"
    }

    # Step 3: Log Standard Output Object
    Write-Host "`n[3/3] Generating Audit Report..." -ForegroundColor Yellow
    
    [PSCustomObject]@{
        ExecutionTime     = $StartTime
        TargetInstance    = $SqlInstance
        SourceDatabase    = $DatabaseName
        StagingDatabase   = $StagingDbName
        RestoreSuccessful = ($TestResult.RestoreResult -eq "Success")
        CheckDbSuccessful = ($TestResult.CheckDbResult -eq "Success")
        DurationMinutes   = $DurationMinutes
        OverallOutcome    = $Outcome
    } | Format-Table -AutoSize

}
catch {
    Write-Error "DR Restore Verification Failed: $_"
    exit 1
}
