# Section03-CreateServiceAccounts.ps1
# Section 3: Create Service Accounts (For Kerberoasting)

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 3: Creating Service Accounts" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$serviceAccounts = @(
    @{
        Name = "SQL Service Account"
        GivenName = "SQL"
        Surname = "Service"
        SAM = "svc_sql"
        Description = "SQL Server Service Account"
        SPNs = @("MSSQLSvc/sqlserver.$script:domainName:1433")
    },
    @{
        Name = "Web Service Account"
        GivenName = "Web"
        Surname = "Service"
        SAM = "svc_web"
        Description = "Web Application Service Account"
        SPNs = @("HTTP/webapp.$script:domainName", "HTTP/webapp")
    },
    @{
        Name = "IIS Service Account"
        GivenName = "IIS"
        Surname = "Service"
        SAM = "svc_iis"
        Description = "IIS Application Pool Service Account"
        SPNs = @("HTTP/iis.$script:domainName", "HTTP/iis")
    },
    @{
        Name = "SharePoint Service Account"
        GivenName = "SharePoint"
        Surname = "Service"
        SAM = "svc_sharepoint"
        Description = "SharePoint Service Account"
        SPNs = @("HTTP/sharepoint.$script:domainName")
    }
)

foreach ($svc in $serviceAccounts) {
    Write-Host "[*] Creating service account: $($svc.SAM)..." -ForegroundColor Yellow
    try {
        $existing = Get-ADUser -Filter "SamAccountName -eq '$($svc.SAM)'" -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "[+] Service account already exists: $($svc.SAM)" -ForegroundColor Green
        } else {
            New-ADUser -Name $svc.Name -GivenName $svc.GivenName -Surname $svc.Surname `
                -SamAccountName $svc.SAM `
                -UserPrincipalName "$($svc.SAM)@$script:domainName" `
                -AccountPassword $script:passwordSecure `
                -Enabled $true `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Description $svc.Description `
                -ErrorAction Stop
            Write-Host "[+] Created service account: $($svc.SAM)" -ForegroundColor Green
        }
        
        # Register SPNs
        foreach ($spn in $svc.SPNs) {
            try {
                $fullName = "$script:domainNetbios\$($svc.SAM)"
                setspn -S $spn $fullName 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "    [+] Registered SPN: $spn" -ForegroundColor Gray
                } else {
                    Write-Host "    [!] SPN already exists or error: $spn" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "    [!] Failed to register SPN $spn - $_" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "[!] ERROR: Failed to create service account $($svc.SAM) - $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Section 3 Complete!" -ForegroundColor Green
Write-Host ""

