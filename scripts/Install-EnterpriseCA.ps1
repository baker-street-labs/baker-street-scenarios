# Install-EnterpriseCA.ps1
# Install and configure Enterprise Root CA for Platform Range
# Execute on AD01 (platform.bakerstreetlabs.io) as Administrator

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Enterprise CA Installation - Platform Range" -ForegroundColor Cyan
Write-Host "Domain: platform.bakerstreetlabs.io" -ForegroundColor Yellow
Write-Host "CA Name: Platform-Root-CA" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
Write-Host "[*] Checking administrator privileges..." -ForegroundColor Yellow
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin)
{
    Write-Host "[!] ERROR: Script must be run as Administrator" -ForegroundColor Red
    exit 1
}
Write-Host "[+] Running with administrator privileges" -ForegroundColor Green
Write-Host ""

# Step 1: Check if AD-Certificate feature is installed
Write-Host "[*] Checking for AD-Certificate feature..." -ForegroundColor Yellow
$feature = Get-WindowsFeature -Name AD-Certificate -ErrorAction SilentlyContinue

if ($feature.Installed)
{
    Write-Host "[+] AD-Certificate feature is already installed" -ForegroundColor Green
}
else
{
    Write-Host "[*] Installing AD-Certificate feature (this may take several minutes)..." -ForegroundColor Yellow
    try
    {
        Install-WindowsFeature -Name AD-Certificate -IncludeManagementTools -ErrorAction Stop
        Write-Host "[+] AD-Certificate feature installed successfully" -ForegroundColor Green
    }
    catch
    {
        Write-Host "[!] ERROR: Failed to install AD-Certificate feature - $_" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# Step 2: Check if CA is configured
Write-Host "[*] Checking if CA is configured..." -ForegroundColor Yellow
$caConfigured = $false

# Check registry for CA configuration
$caRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration"
if (Test-Path $caRegPath)
{
    $caReg = Get-ItemProperty -Path $caRegPath -ErrorAction SilentlyContinue
    if ($caReg)
    {
        $caConfigured = $true
        Write-Host "[+] CA is already configured" -ForegroundColor Green
        Write-Host "[+] CA Registry found" -ForegroundColor Gray
    }
}

if (-not $caConfigured)
{
    Write-Host "[*] Configuring Enterprise Root CA..." -ForegroundColor Yellow
    Write-Host "    CA Name: Platform-Root-CA" -ForegroundColor Gray
    Write-Host "    CA Type: Enterprise Root CA" -ForegroundColor Gray
    Write-Host "    (This may take 2-5 minutes)" -ForegroundColor Gray
    Write-Host ""
    
    try
    {
        # Import ADCSDeployment module
        Import-Module ADCSDeployment -ErrorAction Stop
        
        # Install AD CS Certification Authority
        Install-AdcsCertificationAuthority `
            -CAType EnterpriseRootCA `
            -CACommonName "Platform-Root-CA" `
            -KeyLength 2048 `
            -HashAlgorithmName SHA256 `
            -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
            -ValidityPeriod Years `
            -ValidityPeriodUnits 10 `
            -Force `
            -ErrorAction Stop
        
        Write-Host "[+] Enterprise Root CA configured successfully" -ForegroundColor Green
        Write-Host "[+] CA Name: Platform-Root-CA" -ForegroundColor Green
        Write-Host "[+] Validity: 10 years" -ForegroundColor Gray
        
        # Wait for service to start
        Write-Host "[*] Waiting for Certificate Services to start..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
        # Set service to Automatic and start
        Set-Service -Name CertSvc -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name CertSvc -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5
    }
    catch
    {
        Write-Host "[!] ERROR: Failed to configure CA - $_" -ForegroundColor Red
        Write-Host "[!] Error details: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# Step 3: Verify CA service is running
Write-Host "[*] Verifying Certificate Services..." -ForegroundColor Yellow
try
{
    $caService = Get-Service -Name CertSvc -ErrorAction Stop
    
    if ($caService.Status -eq "Running")
    {
        Write-Host "[+] Certificate Services is running" -ForegroundColor Green
    }
    else
    {
        Write-Host "[*] Starting Certificate Services..." -ForegroundColor Yellow
        Set-Service -Name CertSvc -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name CertSvc -ErrorAction Stop
        Start-Sleep -Seconds 5
        
        $caService = Get-Service -Name CertSvc -ErrorAction Stop
        if ($caService.Status -eq "Running")
        {
            Write-Host "[+] Certificate Services started" -ForegroundColor Green
        }
        else
        {
            Write-Host "[!] WARNING: Certificate Services may not be running yet" -ForegroundColor Yellow
            Write-Host "[!] Service Status: $($caService.Status)" -ForegroundColor Yellow
            Write-Host "[!] Try restarting the service manually if needed" -ForegroundColor Yellow
        }
    }
}
catch
{
    Write-Host "[!] ERROR: Certificate Services not available - $_" -ForegroundColor Red
    Write-Host "[!] The CA may still be configured. Check with: certutil -getconfig" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Display CA information
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Enterprise CA Installation Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try
{
    $caInfo = certutil -getconfig 2>&1
    Write-Host "[+] CA Configuration:" -ForegroundColor Green
    Write-Host "    $($caInfo | Select-Object -First 1)" -ForegroundColor Gray
    
    # Get CA certificate info
    $caCert = certutil -ca.cert 2>&1 | Select-String "Subject:" | Select-Object -First 1
    if ($caCert)
    {
        Write-Host "[+] CA Certificate: $caCert" -ForegroundColor Gray
    }
}
catch
{
    Write-Host "[!] Could not retrieve detailed CA info" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Run Create-ESC1Template-Platform.ps1 to create vulnerable certificate template" -ForegroundColor White
Write-Host "  2. Verify template: certutil -CATemplates" -ForegroundColor White
Write-Host "  3. Test ESC1 attack with Certify.exe" -ForegroundColor White
Write-Host ""

