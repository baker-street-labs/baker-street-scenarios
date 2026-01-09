# Section09-MoveUsersToOUs.ps1
# Section 9: Move Users to Organizational Units

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 9: Moving Users to Organizational Units" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Moving service accounts..." -ForegroundColor Yellow
try {
    Get-ADUser -Filter {SamAccountName -like "svc_*"} | ForEach-Object {
        try {
            Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Demo_ServiceAccounts,$script:domainDN" -ErrorAction Stop
            Write-Host "[+] Moved: $($_.SamAccountName)" -ForegroundColor Green
        } catch {
            # Already in correct OU or move failed
        }
    }
} catch {
    Write-Host "[!] Warning: Could not move service accounts - $_" -ForegroundColor Yellow
}

Write-Host "[*] Moving admin accounts..." -ForegroundColor Yellow
try {
    Get-ADUser -Filter {SamAccountName -like "*admin*"} | ForEach-Object {
        try {
            Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Demo_Admins,$script:domainDN" -ErrorAction Stop
            Write-Host "[+] Moved: $($_.SamAccountName)" -ForegroundColor Green
        } catch {
            # Already in correct OU or move failed
        }
    }
} catch {
    Write-Host "[!] Warning: Could not move admin accounts - $_" -ForegroundColor Yellow
}

Write-Host "[*] Moving standard users and special accounts..." -ForegroundColor Yellow
try {
    $usersToMove = @("jsmith", "jdoe", "bjohnson", "awilliams", "cbrown", "dprince", "enorton", "fgreen", "gmiller", "hdavis", "insider", "targetuser", "nopreauth1", "nopreauth2", "legacyapp")
    foreach ($userSAM in $usersToMove) {
        try {
            $user = Get-ADUser -Filter "SamAccountName -eq '$userSAM'" -ErrorAction SilentlyContinue
            if ($user) {
                Move-ADObject -Identity $user.DistinguishedName -TargetPath "OU=Demo_Users,$script:domainDN" -ErrorAction Stop
                Write-Host "[+] Moved: $userSAM" -ForegroundColor Green
            }
        } catch {
            # Already in correct OU or move failed
        }
    }
} catch {
    Write-Host "[!] Warning: Could not move standard users - $_" -ForegroundColor Yellow
}

Write-Host "[*] Moving computers..." -ForegroundColor Yellow
try {
    Get-ADComputer -Filter {Name -like "CLIENT*" -or Name -like "platform*" -and Name -like "*client*"} | ForEach-Object {
        try {
            Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Demo_Computers,$script:domainDN" -ErrorAction Stop
            Write-Host "[+] Moved computer: $($_.Name)" -ForegroundColor Green
        } catch {
            # Already in correct OU or move failed
        }
    }
} catch {
    Write-Host "[!] Warning: Could not move computers - $_" -ForegroundColor Yellow
}

Write-Host "[*] Moving servers..." -ForegroundColor Yellow
try {
    Get-ADComputer -Filter {Name -like "*AD02*" -or Name -like "*WINSRV*"} | ForEach-Object {
        try {
            Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Demo_Servers,$script:domainDN" -ErrorAction Stop
            Write-Host "[+] Moved server: $($_.Name)" -ForegroundColor Green
        } catch {
            # Already in correct OU or move failed
        }
    }
} catch {
    Write-Host "[!] Warning: Could not move servers - $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Section 9 Complete!" -ForegroundColor Green
Write-Host ""

