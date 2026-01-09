# Validate-All-Scripts.ps1
# Validates syntax of all Platform Range scripts

$scriptFiles = Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" | Where-Object { $_.Name -ne "Validate-All-Scripts.ps1" }

Write-Host "Validating $($scriptFiles.Count) PowerShell scripts..." -ForegroundColor Cyan
Write-Host ""

$hasErrors = $false

foreach ($file in $scriptFiles) {
    Write-Host "Checking $($file.Name)..." -ForegroundColor Yellow
    
    $errors = $null
    $content = Get-Content $file.FullName -Raw
    
    # Parse the script
    $null = [System.Management.Automation.PSParser]::Tokenize($content, [ref]$errors)
    
    if ($errors) {
        Write-Host "  ❌ Syntax errors found:" -ForegroundColor Red
        foreach ($err in $errors) {
            Write-Host "     Line $($err.Token.StartLine): $($err.Message)" -ForegroundColor Red
        }
        $hasErrors = $true
    } else {
        Write-Host "  ✅ OK" -ForegroundColor Green
    }
    
    # Count braces
    $openBraces = ([regex]::Matches($content, '\{')).Count
    $closeBraces = ([regex]::Matches($content, '\}')).Count
    
    if ($openBraces -ne $closeBraces) {
        Write-Host "  ⚠️  Brace mismatch: $openBraces open, $closeBraces close" -ForegroundColor Yellow
        $hasErrors = $true
    }
}

Write-Host ""
if ($hasErrors) {
    Write-Host "❌ VALIDATION FAILED - Fix syntax errors above" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ ALL SCRIPTS VALIDATED SUCCESSFULLY" -ForegroundColor Green
    exit 0
}

