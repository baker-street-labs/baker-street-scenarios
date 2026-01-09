# Section07-CreateTargetUser.ps1
# Section 7: Create Target User for Shadow Credentials

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 7: Creating Shadow Credentials Target" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Creating target user for Shadow Credentials attack..." -ForegroundColor Yellow
try {
    $existing = Get-ADUser -Filter {SamAccountName -eq "targetuser"} -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "[+] Target user already exists" -ForegroundColor Green
    } else {
        New-ADUser -Name "Target User" -GivenName "Target" -Surname "User" `
            -SamAccountName "targetuser" `
            -UserPrincipalName "targetuser@$script:domainName" `
            -AccountPassword $script:passwordSecure `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false `
            -Description "Target for Shadow Credentials demonstration" `
            -ErrorAction Stop
        Write-Host "[+] Created target user: targetuser" -ForegroundColor Green
    }
} catch {
    Write-Host "[!] ERROR: Failed to create target user - $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Section 7 Complete!" -ForegroundColor Green
Write-Host ""

