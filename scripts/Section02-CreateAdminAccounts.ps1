# Section02-CreateAdminAccounts.ps1
# Section 2: Create Administrative Accounts

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 2: Creating Administrative Accounts" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Domain Admin Account
Write-Host "[*] Creating Domain Admin account..." -ForegroundColor Yellow
try {
    # Use Filter to check existence (safer than Identity)
    $existing = Get-ADUser -Filter {SamAccountName -eq "da_admin"} -ErrorAction SilentlyContinue
    
    if ($existing) {
        Write-Host "[+] Domain Admin account already exists" -ForegroundColor Green
    } else {
        New-ADUser -Name "Domain Admin" -GivenName "Domain" -Surname "Admin" `
            -SamAccountName "da_admin" `
            -UserPrincipalName ("da_admin@" + $script:domainName) `
            -AccountPassword $script:passwordSecure `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false `
            -Description "Domain Administrator Account" `
            -ErrorAction Stop
        Add-ADGroupMember -Identity "Domain Admins" -Members "da_admin" -ErrorAction Stop
        Write-Host "[+] Created Domain Admin: da_admin" -ForegroundColor Green
    }
} catch {
    Write-Host "[!] ERROR: Failed to create Domain Admin - $_" -ForegroundColor Red
}

# IT Admin Accounts
Write-Host "[*] Creating IT Admin accounts..." -ForegroundColor Yellow
$itAdmins = @(
    @{GivenName="IT"; Surname="Admin1"; SAM="it_admin1"},
    @{GivenName="IT"; Surname="Admin2"; SAM="it_admin2"}
)

foreach ($admin in $itAdmins) {
    try {
        $existing = Get-ADUser -Filter "SamAccountName -eq '$($admin.SAM)'" -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "[+] IT Admin already exists: $($admin.SAM)" -ForegroundColor Green
        } else {
            New-ADUser -Name "$($admin.GivenName) $($admin.Surname)" -GivenName $admin.GivenName -Surname $admin.Surname `
                -SamAccountName $admin.SAM `
                -UserPrincipalName "$($admin.SAM)@$script:domainName" `
                -AccountPassword $script:passwordSecure `
                -Enabled $true `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Description "IT Administrator" `
                -ErrorAction Stop
            Add-ADGroupMember -Identity "Administrators" -Members $admin.SAM -ErrorAction Stop
            Write-Host "[+] Created IT Admin: $($admin.SAM)" -ForegroundColor Green
        }
    } catch {
        Write-Host "[!] ERROR: Failed to create IT Admin $($admin.SAM) - $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Section 2 Complete!" -ForegroundColor Green
Write-Host ""

