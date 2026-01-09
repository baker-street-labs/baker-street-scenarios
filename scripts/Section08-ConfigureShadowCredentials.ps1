# Section08-ConfigureShadowCredentials.ps1
# Section 8: Configure Shadow Credentials Permissions

. "$PSScriptRoot\Platform-AD-Common.ps1"
Initialize-PlatformAD -SkipAdminCheck

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 8: Configuring Shadow Credentials Permissions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Granting Shadow Credentials permissions..." -ForegroundColor Yellow
try {
    $targetUser = Get-ADUser -Filter {SamAccountName -eq "targetuser"} -ErrorAction Stop
    $insiderUser = Get-ADUser -Filter {SamAccountName -eq "insider"} -ErrorAction Stop
    
    $targetDN = $targetUser.DistinguishedName
    $insiderSID = $insiderUser.SID
    
    $acl = Get-Acl "AD:$targetDN"
    $identity = [System.Security.Principal.SecurityIdentifier]$insiderSID
    $adRights = [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty
    $type = [System.Security.AccessControl.AccessControlType]::Allow
    $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None
    $objectType = [GUID]"5b47d60f-6090-40b2-9f37-2a4de88f3063"
    
    # Check if permission already exists
    $existingPerm = $acl.Access | Where-Object {
        $_.IdentityReference -like "*insider*" -and
        $_.ActiveDirectoryRights -eq $adRights -and
        $_.ObjectType -eq $objectType
    }
    
    if (-not $existingPerm) {
        $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, $adRights, $type, $objectType, $inheritanceType)
        $acl.AddAccessRule($ace)
        Set-Acl -Path "AD:$targetDN" -AclObject $acl -ErrorAction Stop
        Write-Host "[+] Shadow Credentials permissions configured" -ForegroundColor Green
        Write-Host "    insider can write msDS-KeyCredentialLink on targetuser" -ForegroundColor Gray
    } else {
        Write-Host "[+] Shadow Credentials permissions already configured" -ForegroundColor Green
    }
} catch {
    Write-Host "[!] ERROR: Failed to configure Shadow Credentials permissions - $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Section 8 Complete!" -ForegroundColor Green
Write-Host ""

