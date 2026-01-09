# Test SSH Access to All Cyber Ranges
# Standard Ports: linsrv 42422, engine 42423, signals 42424, AD01 42425, AD02 42426, WinSrv 42427, client01 42428, client02 42429, client03 42430

$ranges = @{
    "Range XDR" = @{
        NAT_IP = "192.168.255.250"
        Domain = "xdr"
        AD01_Port = 42425
        AD02_Port = 42426
        WinSrv_Port = 42427
        Client01_Port = 42428
        Client02_Port = 42429
        Client03_Port = 42430
    }
    "Range XSIAM" = @{
        NAT_IP = "192.168.255.251"
        Domain = "xsiam"
        AD01_Port = 42425
        AD02_Port = 42426
        WinSrv_Port = 42427
        Client01_Port = 42428
        Client02_Port = 42429
        Client03_Port = 42430
    }
    "Range Agentix" = @{
        NAT_IP = "192.168.255.252"
        Domain = "agentix"
        AD01_Port = 42425
        AD02_Port = 42426
        WinSrv_Port = 42427
        Client01_Port = 42428
        Client02_Port = 42429
        Client03_Port = 42430
    }
}

$sshKey = "$env:USERPROFILE\.ssh\id_rsa"
$results = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SSH Access Test - All Cyber Ranges" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($rangeName in $ranges.Keys) {
    $range = $ranges[$rangeName]
    Write-Host "[*] Testing $rangeName (NAT IP: $($range.NAT_IP))" -ForegroundColor Yellow
    Write-Host ""
    
    # Test AD01
    $user = "$($range.Domain)\administrator"
    $port = $range.AD01_Port
    Write-Host "  Testing AD01 - Port $port ($user)..." -ForegroundColor Gray
    
    $testCmd = "ssh -i `"$sshKey`" -p $port -o StrictHostKeyChecking=no -o ConnectTimeout=5 $user@$($range.NAT_IP) `"hostname`" 2>&1"
    $output = Invoke-Expression $testCmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [+] SUCCESS - AD01 accessible on port $port" -ForegroundColor Green
        $results += [PSCustomObject]@{
            Range = $rangeName
            System = "AD01"
            NAT_IP = $range.NAT_IP
            Port = $port
            User = $user
            Status = "SUCCESS"
            Hostname = $output.Trim()
        }
    } else {
        Write-Host "    [-] FAILED - AD01 not accessible on port $port" -ForegroundColor Red
        Write-Host "      Error: $output" -ForegroundColor DarkRed
        $results += [PSCustomObject]@{
            Range = $rangeName
            System = "AD01"
            NAT_IP = $range.NAT_IP
            Port = $port
            User = $user
            Status = "FAILED"
            Hostname = ""
        }
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$results | Format-Table -AutoSize

# Export results
$results | Export-Csv -Path ".\SSH-Access-Test-Results.csv" -NoTypeInformation
Write-Host "Results saved to: .\SSH-Access-Test-Results.csv" -ForegroundColor Cyan
Write-Host ""

