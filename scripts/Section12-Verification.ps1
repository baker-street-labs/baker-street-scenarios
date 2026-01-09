# Section12-Verification.ps1
# Section 12: Configuration Verification

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 12: Configuration Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Verifying configuration..." -ForegroundColor Yellow

# Count users
$totalUsers = (Get-ADUser -Filter *).Count
$adminUsers = (Get-ADUser -Filter {SamAccountName -like "*admin*"}).Count
$serviceUsers = (Get-ADUser -Filter {SamAccountName -like "svc_*"}).Count
$nopreauthCount = (Get-ADUser -Filter * -Properties DoesNotRequirePreAuth | Where-Object {$_.DoesNotRequirePreAuth -eq $true}).Count
$spnCount = (Get-ADUser -Filter {ServicePrincipalName -like "*"} -Properties ServicePrincipalName).Count

Write-Host ""
Write-Host "=== CONFIGURATION SUMMARY ===" -ForegroundColor Yellow
Write-Host "Total Users: $totalUsers" -ForegroundColor Green
Write-Host "Administrative Accounts: $adminUsers" -ForegroundColor Green
Write-Host "Service Accounts: $serviceUsers" -ForegroundColor Green
Write-Host "AS-REP Roastable Accounts: $nopreauthCount" -ForegroundColor Green
Write-Host "Accounts with SPNs: $spnCount" -ForegroundColor Green
Write-Host ""

# Verify key accounts exist
$keyAccounts = @("insider", "targetuser", "da_admin", "svc_sql", "nopreauth1")

Write-Host "=== KEY ACCOUNTS ===" -ForegroundColor Yellow
foreach ($account in $keyAccounts)
{
    $user = Get-ADUser -Filter "SamAccountName -eq '$account'" -ErrorAction SilentlyContinue
    if ($user)
    {
        Write-Host "[✓] $account exists" -ForegroundColor Green
    }
    else
    {
        Write-Host "[✗] $account MISSING" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== ORGANIZATIONAL UNITS ===" -ForegroundColor Yellow

# Verify OUs exist
$ouList = Get-ADOrganizationalUnit -Filter 'Name -like "Demo_*"' -SearchBase $script:domainDN -ErrorAction SilentlyContinue
if ($ouList)
{
    foreach ($ou in $ouList)
    {
        $count = (Get-ADObject -Filter * -SearchBase $ou.DistinguishedName -SearchScope OneLevel -ErrorAction SilentlyContinue).Count
        Write-Host "[✓] $($ou.Name) - $count objects" -ForegroundColor Green
    }
}
else
{
    Write-Host "[!] No Demo_* OUs found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[+] All users created with password: $script:defaultPassword" -ForegroundColor Green
Write-Host "[+] All configurations applied" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Verify certificate template is configured (ESC1 vulnerability)" -ForegroundColor White
Write-Host "  2. Test insider account login: platform\\insider" -ForegroundColor White
Write-Host "  3. Verify SPNs are registered: setspn -Q */svc_sql" -ForegroundColor White
Write-Host "  4. Test AS-REP roasting on nopreauth1 account" -ForegroundColor White
Write-Host "  5. Create Pre-Attack snapshot" -ForegroundColor White
Write-Host ""
