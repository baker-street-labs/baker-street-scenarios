# Section05-CreateASREPRoastable.ps1
# Section 5: Create Vulnerable User Accounts (AS-REP Roasting)

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 5: Creating AS-REP Roastable Accounts" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$nopreauthUsers = @(
    @{GivenName="NoPreAuth"; Surname="User1"; SAM="nopreauth1"; Description="User without Kerberos pre-authentication (VULNERABLE)"},
    @{GivenName="NoPreAuth"; Surname="User2"; SAM="nopreauth2"; Description="User without Kerberos pre-authentication (VULNERABLE)"},
    @{GivenName="Legacy"; Surname="App"; SAM="legacyapp"; Description="Legacy application account - Pre-auth disabled for compatibility"}
)

foreach ($user in $nopreauthUsers) {
    Write-Host "[*] Creating AS-REP roastable account: $($user.SAM)..." -ForegroundColor Yellow
    try {
        $existing = Get-ADUser -Filter "SamAccountName -eq '$($user.SAM)'" -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "[+] User already exists: $($user.SAM)" -ForegroundColor Green
        } else {
            New-ADUser -Name "$($user.GivenName) $($user.Surname)" `
                -GivenName $user.GivenName `
                -Surname $user.Surname `
                -SamAccountName $user.SAM `
                -UserPrincipalName "$($user.SAM)@$script:domainName" `
                -AccountPassword $script:passwordSecure `
                -Enabled $true `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Description $user.Description `
                -ErrorAction Stop
            Write-Host "[+] Created user: $($user.SAM)" -ForegroundColor Green
        }
        
        # Disable Kerberos pre-authentication
        Set-ADAccountControl -Identity $user.SAM -DoesNotRequirePreAuth $true -ErrorAction Stop
        Write-Host "    [+] Disabled Kerberos pre-authentication" -ForegroundColor Green
    } catch {
        Write-Host "[!] ERROR: Failed to create AS-REP roastable account $($user.SAM) - $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Section 5 Complete!" -ForegroundColor Green
Write-Host ""

