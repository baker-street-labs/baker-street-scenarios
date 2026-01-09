# Section11-ConfigureLockoutPolicy.ps1
# Section 11: Configure Account Lockout Policy

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 11: Configuring Account Lockout Policy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Configuring account lockout policy..." -ForegroundColor Yellow
Write-Host "[!] Setting lockout threshold to 0 (disabled for demo purposes)" -ForegroundColor Yellow
try {
    net accounts /lockoutthreshold:0 2>&1 | Out-Null
    net accounts /lockoutduration:30 2>&1 | Out-Null
    net accounts /lockoutwindow:30 2>&1 | Out-Null
    Write-Host "[+] Account lockout policy configured" -ForegroundColor Green
    Write-Host "    Lockout threshold: 0 (disabled for demo)" -ForegroundColor Gray
} catch {
    Write-Host "[!] Warning: Could not configure lockout policy - $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Section 11 Complete!" -ForegroundColor Green
Write-Host ""

