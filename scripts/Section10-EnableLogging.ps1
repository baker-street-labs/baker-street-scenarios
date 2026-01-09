# Section10-EnableLogging.ps1
# Section 10: Enable Enhanced Logging

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 10: Enabling Enhanced Logging" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Configuring AD auditing policies..." -ForegroundColor Yellow
$auditPolicies = @(
    "Directory Service Access",
    "Directory Service Changes",
    "Kerberos Authentication Service",
    "Kerberos Service Ticket Operations"
)

foreach ($policy in $auditPolicies) {
    try {
        auditpol /set /subcategory:"$policy" /success:enable /failure:enable 2>&1 | Out-Null
        Write-Host "[+] Enabled auditing: $policy" -ForegroundColor Green
    } catch {
        Write-Host "[!] Warning: Could not enable auditing for $policy - $_" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Section 10 Complete!" -ForegroundColor Green
Write-Host ""

