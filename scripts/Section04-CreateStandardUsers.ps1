# Section04-CreateStandardUsers.ps1
# Section 4: Create Standard User Accounts

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 4: Creating Standard User Accounts" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$users = @(
    @{FirstName="John"; LastName="Smith"; SAM="jsmith"},
    @{FirstName="Jane"; LastName="Doe"; SAM="jdoe"},
    @{FirstName="Bob"; LastName="Johnson"; SAM="bjohnson"},
    @{FirstName="Alice"; LastName="Williams"; SAM="awilliams"},
    @{FirstName="Charlie"; LastName="Brown"; SAM="cbrown"},
    @{FirstName="Diana"; LastName="Prince"; SAM="dprince"},
    @{FirstName="Edward"; LastName="Norton"; SAM="enorton"},
    @{FirstName="Fiona"; LastName="Green"; SAM="fgreen"},
    @{FirstName="George"; LastName="Miller"; SAM="gmiller"},
    @{FirstName="Hannah"; LastName="Davis"; SAM="hdavis"}
)

foreach ($user in $users) {
    try {
        $existing = Get-ADUser -Filter "SamAccountName -eq '$($user.SAM)'" -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "[+] User already exists: $($user.SAM)" -ForegroundColor Green
        } else {
            New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
                -GivenName $user.FirstName `
                -Surname $user.LastName `
                -SamAccountName $user.SAM `
                -UserPrincipalName "$($user.SAM)@$script:domainName" `
                -AccountPassword $script:passwordSecure `
                -Enabled $true `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Description "Standard User Account" `
                -ErrorAction Stop
            Write-Host "[+] Created user: $($user.SAM)" -ForegroundColor Green
        }
    } catch {
        Write-Host "[!] ERROR: Failed to create user $($user.SAM) - $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Section 4 Complete!" -ForegroundColor Green
Write-Host ""

