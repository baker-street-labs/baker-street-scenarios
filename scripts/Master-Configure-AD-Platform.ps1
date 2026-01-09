# Master-Configure-AD-Platform.ps1
# Master orchestrator script for Platform Range AD Configuration
# Executes all section scripts in sequence with error handling

param(
    [int]$StartFromSection = 1,
    [int]$StopAtSection = 12,
    [switch]$SkipVerification
)

$ErrorActionPreference = "Continue"
$scriptRoot = $PSScriptRoot
if (-not $scriptRoot) {
    $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Platform Range AD Configuration - Master Script" -ForegroundColor Cyan
Write-Host "Domain: platform.bakerstreetlabs.io" -ForegroundColor Yellow
Write-Host "Starting from Section: $StartFromSection" -ForegroundColor Gray
Write-Host "Stopping at Section: $StopAtSection" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define all section scripts
$sections = @(
    @{Number=1; Name="CreateOUs"; Script="Section01-CreateOUs.ps1"; Description="Create Organizational Units"}
    @{Number=2; Name="CreateAdminAccounts"; Script="Section02-CreateAdminAccounts.ps1"; Description="Create Administrative Accounts"}
    @{Number=3; Name="CreateServiceAccounts"; Script="Section03-CreateServiceAccounts.ps1"; Description="Create Service Accounts"}
    @{Number=4; Name="CreateStandardUsers"; Script="Section04-CreateStandardUsers.ps1"; Description="Create Standard User Accounts"}
    @{Number=5; Name="CreateASREPRoastable"; Script="Section05-CreateASREPRoastable.ps1"; Description="Create AS-REP Roastable Accounts"}
    @{Number=6; Name="CreateInsiderAccount"; Script="Section06-CreateInsiderAccount.ps1"; Description="Create Compromised Insider Account"}
    @{Number=7; Name="CreateTargetUser"; Script="Section07-CreateTargetUser.ps1"; Description="Create Target User for Shadow Credentials"}
    @{Number=8; Name="ConfigureShadowCredentials"; Script="Section08-ConfigureShadowCredentials.ps1"; Description="Configure Shadow Credentials Permissions"}
    @{Number=9; Name="MoveUsersToOUs"; Script="Section09-MoveUsersToOUs.ps1"; Description="Move Users to Organizational Units"}
    @{Number=10; Name="EnableLogging"; Script="Section10-EnableLogging.ps1"; Description="Enable Enhanced Logging"}
    @{Number=11; Name="ConfigureLockoutPolicy"; Script="Section11-ConfigureLockoutPolicy.ps1"; Description="Configure Account Lockout Policy"}
    @{Number=12; Name="Verification"; Script="Section12-Verification.ps1"; Description="Configuration Verification"}
)

$failedSections = @()
$successSections = @()

# Main execution loop
foreach ($section in $sections)
{
    # Check if section is in range
    if ($section.Number -lt $StartFromSection)
    {
        Write-Host "[SKIP] Section $($section.Number): $($section.Description) (before start point)" -ForegroundColor Gray
        continue
    }
    
    if ($section.Number -gt $StopAtSection)
    {
        Write-Host "[SKIP] Section $($section.Number): $($section.Description) (after stop point)" -ForegroundColor Gray
        continue
    }
    
    if ($SkipVerification -and $section.Number -eq 12)
    {
        Write-Host "[SKIP] Section 12: Verification (skipped per -SkipVerification)" -ForegroundColor Gray
        continue
    }
    
    $scriptPath = Join-Path $scriptRoot $section.Script
    
    if (-not (Test-Path $scriptPath))
    {
        Write-Host "[!] ERROR: Section script not found: $scriptPath" -ForegroundColor Red
        $failedSections += $section
        continue
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Executing Section $($section.Number): $($section.Description)" -ForegroundColor Cyan
    Write-Host "Script: $($section.Script)" -ForegroundColor Gray
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Execute section script
    $executeSuccess = $false
    try
    {
        & $scriptPath
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -eq 0 -or $exitCode -eq $null)
        {
            $executeSuccess = $true
        }
    }
    catch
    {
        Write-Host ""
        Write-Host "[!] ERROR: Section $($section.Number) failed - $_" -ForegroundColor Red
        $failedSections += $section
        
        $continue = Read-Host "Continue with next section? (Y/N)"
        if ($continue -ne "Y" -and $continue -ne "y")
        {
            Write-Host "[*] Stopping execution per user request" -ForegroundColor Yellow
            break
        }
    }
    
    # Update status based on result
    if ($executeSuccess)
    {
        Write-Host ""
        Write-Host "[✓] Section $($section.Number) completed successfully" -ForegroundColor Green
        $successSections += $section
    }
    else
    {
        if ($failedSections -notcontains $section)
        {
            Write-Host ""
            Write-Host "[!] Section $($section.Number) completed with exit code: $exitCode" -ForegroundColor Yellow
            $failedSections += $section
        }
    }
    
    Write-Host ""
    Start-Sleep -Seconds 1
}

# Print summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Execution Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($successSections.Count -gt 0)
{
    Write-Host "[+] Successful sections ($($successSections.Count)):" -ForegroundColor Green
    foreach ($section in $successSections)
    {
        Write-Host "    ✓ Section $($section.Number): $($section.Description)" -ForegroundColor Green
    }
}

if ($failedSections.Count -gt 0)
{
    Write-Host ""
    Write-Host "[!] Failed sections ($($failedSections.Count)):" -ForegroundColor Red
    foreach ($section in $failedSections)
    {
        Write-Host "    ✗ Section $($section.Number): $($section.Description)" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "To retry failed sections:" -ForegroundColor Yellow
    Write-Host "  .\Master-Configure-AD-Platform.ps1 -StartFromSection $($failedSections[0].Number) -StopAtSection $($failedSections[-1].Number)" -ForegroundColor Gray
    exit 1
}
else
{
    Write-Host ""
    Write-Host "[+] All sections completed successfully!" -ForegroundColor Green
    exit 0
}
