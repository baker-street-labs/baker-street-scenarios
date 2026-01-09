# Section01-CreateOUs.ps1
# Section 1: Create Organizational Units
# Execute from C:\Scripts\platform\ directory

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 1: Creating Organizational Units" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ous = @(
    @{Name="Demo_Users"; Description="Standard user accounts"},
    @{Name="Demo_Computers"; Description="Workstation computers"},
    @{Name="Demo_ServiceAccounts"; Description="Service accounts"},
    @{Name="Demo_Admins"; Description="Administrative accounts"},
    @{Name="Demo_Servers"; Description="Server computers"}
)

foreach ($ou in $ous) {
    try {
        $existingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$($ou.Name)'" -SearchBase $script:domainDN -ErrorAction SilentlyContinue
        if ($existingOU) {
            Write-Host "[+] OU already exists: $($ou.Name)" -ForegroundColor Green
        } else {
            New-ADOrganizationalUnit -Name $ou.Name -Path $script:domainDN -Description $ou.Description -ErrorAction Stop
            Write-Host "[+] Created OU: $($ou.Name)" -ForegroundColor Green
        }
    } catch {
        Write-Host "[!] Warning: Could not create OU $($ou.Name) - $_" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Section 1 Complete!" -ForegroundColor Green
Write-Host ""

