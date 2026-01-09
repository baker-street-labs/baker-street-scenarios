# Section06-CreateInsiderAccount.ps1
# Section 6: Create Compromised Insider Account

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 6: Creating Compromised Insider Account" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Creating compromised insider account..." -ForegroundColor Yellow
try {
    $existing = Get-ADUser -Filter {SamAccountName -eq "insider"} -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "[+] Insider account already exists" -ForegroundColor Green
    } else {
        New-ADUser -Name "Insider Threat" -GivenName "Insider" -Surname "Threat" `
            -SamAccountName "insider" `
            -UserPrincipalName "insider@$script:domainName" `
            -AccountPassword $script:passwordSecure `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false `
            -Description "Standard user account - COMPROMISED by attacker (demo starting point)" `
            -ErrorAction Stop
        Write-Host "[+] Created insider account: insider" -ForegroundColor Green
        Write-Host "    Password: $script:defaultPassword" -ForegroundColor Gray
    }
} catch {
    Write-Host "[!] ERROR: Failed to create insider account - $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Section 6 Complete!" -ForegroundColor Green
Write-Host ""

