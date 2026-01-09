# Platform-AD-Common.ps1
# Common configuration and initialization for Platform Range AD scripts
# Source this file in all section scripts

$ErrorActionPreference = "Continue"
$OutputEncoding = [System.Text.Encoding]::UTF8

# Configuration variables - Platform Range (standalone forest)
$script:domainName = "platform.bakerstreetlabs.io"
$script:domainDN = "DC=platform,DC=bakerstreetlabs,DC=io"
$script:domainNetbios = "PLATFORM"
$script:defaultPassword = "Cortex1!"
$script:passwordSecure = ConvertTo-SecureString $script:defaultPassword -AsPlainText -Force

# Initialize function
function Initialize-PlatformAD {
    param(
        [switch]$SkipAdminCheck
    )
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Platform Range AD Configuration" -ForegroundColor Cyan
    Write-Host "Domain: $script:domainName" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if running as administrator
    if (-not $SkipAdminCheck) {
        Write-Host "[*] Checking administrator privileges..." -ForegroundColor Yellow
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
        $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if (-not $isAdmin) {
            Write-Host "[!] ERROR: Script must be run as Administrator" -ForegroundColor Red
            exit 1
        }
        Write-Host "[+] Running with administrator privileges" -ForegroundColor Green
        Write-Host ""
    }
    
    # Import Active Directory module
    Write-Host "[*] Importing Active Directory module..." -ForegroundColor Yellow
    try {
        Import-Module ActiveDirectory -ErrorAction Stop
        Write-Host "[+] Active Directory module loaded" -ForegroundColor Green
    } catch {
        Write-Host "[!] ERROR: Failed to load Active Directory module - $_" -ForegroundColor Red
        Write-Host "[!] Active Directory Domain Services may not be installed" -ForegroundColor Yellow
        exit 1
    }
    Write-Host ""
    
    # Verify domain
    Write-Host "[*] Verifying domain..." -ForegroundColor Yellow
    try {
        $domain = Get-ADDomain -ErrorAction Stop
        Write-Host "[+] Domain reachable: $($domain.DNSRoot)" -ForegroundColor Green
        
        if ($domain.DNSRoot -ne $script:domainName) {
            Write-Host "[!] WARNING: Current domain ($($domain.DNSRoot)) differs from expected ($script:domainName)" -ForegroundColor Yellow
            $script:domainDN = $domain.DistinguishedName
        } else {
            Write-Host "[+] Correct domain detected: $script:domainName" -ForegroundColor Green
        }
        
        Write-Host "[+] Distinguished Name: $script:domainDN" -ForegroundColor Gray
    } catch {
        Write-Host "[!] ERROR: Could not contact domain - $_" -ForegroundColor Red
        Write-Host "[!] Ensure this server is a Domain Controller" -ForegroundColor Yellow
        exit 1
    }
    Write-Host ""
}

