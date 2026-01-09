# Check-CA-Status.ps1
# Diagnostic script to check CA installation status

Write-Host "=== CA Feature Status ===" -ForegroundColor Cyan
Get-WindowsFeature -Name AD-Certificate | Format-Table Name, InstallState, Installed

Write-Host "`n=== Certificate Service Status ===" -ForegroundColor Cyan
$service = Get-Service -Name CertSvc -ErrorAction SilentlyContinue
if ($service) {
    $service | Format-List Name, Status, StartType
} else {
    Write-Host "CertSvc service not found" -ForegroundColor Red
}

Write-Host "`n=== CA Configuration ===" -ForegroundColor Cyan
$caConfig = certutil -getconfig 2>&1
$caConfig | Select-Object -First 10

Write-Host "`n=== CA Registry ===" -ForegroundColor Cyan
$caReg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration" -ErrorAction SilentlyContinue
if ($caReg) {
    $caReg | Format-List
} else {
    Write-Host "CA Configuration registry not found" -ForegroundColor Yellow
}

Write-Host "`n=== ADCS PowerShell Module ===" -ForegroundColor Cyan
if (Get-Module -ListAvailable -Name ADCSDeployment) {
    Write-Host "ADCSDeployment module is available" -ForegroundColor Green
    Import-Module ADCSDeployment -ErrorAction SilentlyContinue
    Get-Command -Module ADCSDeployment | Select-Object Name
} else {
    Write-Host "ADCSDeployment module not found" -ForegroundColor Yellow
}

