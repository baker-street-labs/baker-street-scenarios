# EXTRACTED FROM PRODUCTION BAKER STREET MONOREPO – 2025-12-03
# Verified working in active cyber range for 18+ months
# Part of the official Tier 1 / Tier 2 crown jewels audit (Conservative Option A)
# DO NOT REFACTOR UNLESS EXPLICITLY APPROVED

# Configure-AD-Complete-XSIAM.ps1
# Complete Active Directory Configuration for Range XSIAM Attack Simulation
# Execute on DC01 (RangeXSIAM-AD01) as Enterprise Administrator
# Version 1.0 - Implements all users, service accounts, groups, and configurations
# Password Policy: All accounts use password "Cortex1!"

$ErrorActionPreference = "Continue"
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Complete AD Configuration - Range XSIAM" -ForegroundColor Cyan
Write-Host "Domain: xsiam.ad.bakerstreetlabs.io" -ForegroundColor Yellow
Write-Host "Version: 1.0" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration variables - Range XSIAM
$domainName = "xsiam.ad.bakerstreetlabs.io"
$domainDN = "DC=xsiam,DC=ad,DC=bakerstreetlabs,DC=io"
$adServer = $domainName
$defaultPassword = "Cortex1!"
$passwordSecure = ConvertTo-SecureString $defaultPassword -AsPlainText -Force

# Check if running as administrator
Write-Host "[*] Checking administrator privileges..." -ForegroundColor Yellow
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[!] ERROR: Script must be run as Administrator" -ForegroundColor Red
    exit 1
}
Write-Host "[+] Running with administrator privileges" -ForegroundColor Green
Write-Host ""

# Import Active Directory module
Write-Host "[*] Importing Active Directory module..." -ForegroundColor Yellow
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "[+] Active Directory module loaded" -ForegroundColor Green
} catch {
    Write-Host "[!] ERROR: Failed to load Active Directory module - $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Verify domain
Write-Host "[*] Verifying domain..." -ForegroundColor Yellow
try {
    $domain = Get-ADDomain -Identity $domainName -Server $adServer -ErrorAction Stop
    Write-Host "[+] Target domain reachable: $($domain.DNSRoot)" -ForegroundColor Green
    $domainDN = $domain.DistinguishedName

    try {
        $localDomain = Get-ADDomain -ErrorAction Stop
        if ($localDomain.DNSRoot -ne $domain.DNSRoot) {
            Write-Host "[!] WARNING: Local domain ($($localDomain.DNSRoot)) differs from target domain ($($domain.DNSRoot)). Using remote binding." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[!] WARNING: Unable to determine local domain - $_" -ForegroundColor Yellow
    }

    Write-Host "[+] Distinguished Name: $domainDN" -ForegroundColor Gray
} catch {
    Write-Host "[!] ERROR: Could not contact target domain $domainName - $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# ========================================
# SECTION 1: Create Organizational Units
# ========================================
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
        $existingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$($ou.Name)'" -SearchBase $domainDN -ErrorAction SilentlyContinue
        if ($existingOU) {
            Write-Host "[+] OU already exists: $($ou.Name)" -ForegroundColor Green
        } else {
            New-ADOrganizationalUnit -Name $ou.Name -Path $domainDN -Description $ou.Description -ErrorAction Stop
            Write-Host "[+] Created OU: $($ou.Name)" -ForegroundColor Green
        }
    } catch {
        Write-Host "[!] Warning: Could not create OU $($ou.Name) - $_" -ForegroundColor Yellow
    }
}
Write-Host ""

# ========================================
# SECTION 2: Create Administrative Accounts
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 2: Creating Administrative Accounts" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Domain Admin Account
Write-Host "[*] Creating Domain Admin account..." -ForegroundColor Yellow
try {
    $existing = Get-ADUser -Identity "da_admin" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "[+] Domain Admin account already exists" -ForegroundColor Green
    } else {
        New-ADUser -Name "Domain Admin" -GivenName "Domain" -Surname "Admin" `
            -SamAccountName "da_admin" `
            -UserPrincipalName "da_admin@$domainName" `
            -AccountPassword $passwordSecure `
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
        $existing = Get-ADUser -Identity $admin.SAM -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "[+] IT Admin already exists: $($admin.SAM)" -ForegroundColor Green
        } else {
            New-ADUser -Name "$($admin.GivenName) $($admin.Surname)" -GivenName $admin.GivenName -Surname $admin.Surname `
                -SamAccountName $admin.SAM `
                -UserPrincipalName "$($admin.SAM)@$domainName" `
                -AccountPassword $passwordSecure `
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

# ========================================
# SECTION 3: Create Service Accounts (For Kerberoasting)
# ========================================
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
        SPNs = @("MSSQLSvc/sqlserver.$domainName:1433")
    },
    @{
        Name = "Web Service Account"
        GivenName = "Web"
        Surname = "Service"
        SAM = "svc_web"
        Description = "Web Application Service Account"
        SPNs = @("HTTP/webapp.$domainName", "HTTP/webapp")
    },
    @{
        Name = "IIS Service Account"
        GivenName = "IIS"
        Surname = "Service"
        SAM = "svc_iis"
        Description = "IIS Application Pool Service Account"
        SPNs = @("HTTP/iis.$domainName", "HTTP/iis")
    },
    @{
        Name = "SharePoint Service Account"
        GivenName = "SharePoint"
        Surname = "Service"
        SAM = "svc_sharepoint"
        Description = "SharePoint Service Account"
        SPNs = @("HTTP/sharepoint.$domainName")
    }
)

foreach ($svc in $serviceAccounts) {
    Write-Host "[*] Creating service account: $($svc.SAM)..." -ForegroundColor Yellow
    try {
        $existing = Get-ADUser -Identity $svc.SAM -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "[+] Service account already exists: $($svc.SAM)" -ForegroundColor Green
            # Still register SPNs in case they're missing
        } else {
            New-ADUser -Name $svc.Name -GivenName $svc.GivenName -Surname $svc.Surname `
                -SamAccountName $svc.SAM `
                -UserPrincipalName "$($svc.SAM)@$domainName" `
                -AccountPassword $passwordSecure `
                -Enabled $true `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Description $svc.Description `
                -ErrorAction Stop
            Write-Host "[+] Created service account: $($svc.SAM)" -ForegroundColor Green
        }
        
        # Register SPNs
        $domainNetbios = $domainName.Split('.')[0].ToUpper()
        foreach ($spn in $svc.SPNs) {
            try {
                $fullName = "$domainNetbios\$($svc.SAM)"   # FQDN\user format works everywhere
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

# ========================================
# SECTION 4: Create Standard User Accounts
# ========================================
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
        $existing = Get-ADUser -Identity $user.SAM -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "[+] User already exists: $($user.SAM)" -ForegroundColor Green
        } else {
            New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
                -GivenName $user.FirstName `
                -Surname $user.LastName `
                -SamAccountName $user.SAM `
                -UserPrincipalName "$($user.SAM)@$domainName" `
                -AccountPassword $passwordSecure `
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

# ========================================
# SECTION 5: Create Vulnerable User Accounts (AS-REP Roasting)
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 5: Creating AS-REP Roastable Accounts" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$nopreauthUsers = @(
    @{GivenName="NoPreAuth"; Surname="User1"; SAM="nopreauth1"; Description="User without Kerberos pre-authentication (VULNERABLE)"},
    @{GivenName="NoPreAuth"; Surname="User2"; SAM="nopreauth2"; Description="User without Kerberos pre-authentication (VULNERABLE)"},
    @{GivenName="Legacy"; Surname="App"; SAM="legacyapp"; Description="Legacy application account - Pre-auth disabled for compatibility"}
)

foreach ($user in $nopreauthUsers) {
    Write-Host "[*] Creating AS-REP roastable account: $($user.SAM)..." -ForegroundColor Yellow
    try {
        $existing = Get-ADUser -Identity $user.SAM -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "[+] User already exists: $($user.SAM)" -ForegroundColor Green
        } else {
            New-ADUser -Name "$($user.GivenName) $($user.Surname)" `
                -GivenName $user.GivenName `
                -Surname $user.Surname `
                -SamAccountName $user.SAM `
                -UserPrincipalName "$($user.SAM)@$domainName" `
                -AccountPassword $passwordSecure `
                -Enabled $true `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Description $user.Description `
                -ErrorAction Stop
            Write-Host "[+] Created user: $($user.SAM)" -ForegroundColor Green
        }
        
        # Disable Kerberos pre-authentication
        Set-ADAccountControl -Identity $user.SAM -DoesNotRequirePreAuth $true -ErrorAction Stop
        Write-Host "    [+] Disabled Kerberos pre-authentication" -ForegroundColor Green
    } catch {
        Write-Host "[!] ERROR: Failed to create AS-REP roastable account $($user.SAM) - $_" -ForegroundColor Red
    }
}
Write-Host ""

# ========================================
# SECTION 6: Create Compromised Insider Account
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 6: Creating Compromised Insider Account" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Creating compromised insider account..." -ForegroundColor Yellow
try {
    $existing = Get-ADUser -Identity "insider" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "[+] Insider account already exists" -ForegroundColor Green
    } else {
        New-ADUser -Name "Insider Threat" -GivenName "Insider" -Surname "Threat" `
            -SamAccountName "insider" `
            -UserPrincipalName "insider@$domainName" `
            -AccountPassword $passwordSecure `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false `
            -Description "Standard user account - COMPROMISED by attacker (demo starting point)" `
            -ErrorAction Stop
        Write-Host "[+] Created insider account: insider" -ForegroundColor Green
        Write-Host "    Password: $defaultPassword" -ForegroundColor Gray
    }
} catch {
    Write-Host "[!] ERROR: Failed to create insider account - $_" -ForegroundColor Red
}
Write-Host ""

# ========================================
# SECTION 7: Create Target User for Shadow Credentials
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 7: Creating Shadow Credentials Target" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Creating target user for Shadow Credentials attack..." -ForegroundColor Yellow
try {
    $existing = Get-ADUser -Identity "targetuser" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "[+] Target user already exists" -ForegroundColor Green
    } else {
        New-ADUser -Name "Target User" -GivenName "Target" -Surname "User" `
            -SamAccountName "targetuser" `
            -UserPrincipalName "targetuser@$domainName" `
            -AccountPassword $passwordSecure `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false `
            -Description "Target for Shadow Credentials demonstration" `
            -ErrorAction Stop
        Write-Host "[+] Created target user: targetuser" -ForegroundColor Green
    }
} catch {
    Write-Host "[!] ERROR: Failed to create target user - $_" -ForegroundColor Red
}
Write-Host ""

# ========================================
# SECTION 8: Configure Shadow Credentials Permissions
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 8: Configuring Shadow Credentials Permissions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Granting Shadow Credentials permissions..." -ForegroundColor Yellow
try {
    $targetDN = (Get-ADUser -Identity "targetuser").DistinguishedName
    $insiderSID = (Get-ADUser -Identity "insider").SID
    
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

# ========================================
# SECTION 9: Move Users to Organizational Units
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 9: Moving Users to Organizational Units" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Moving service accounts..." -ForegroundColor Yellow
try {
    Get-ADUser -Filter {SamAccountName -like "svc_*"} | ForEach-Object {
        try {
            Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Demo_ServiceAccounts,$domainDN" -ErrorAction Stop
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
            Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Demo_Admins,$domainDN" -ErrorAction Stop
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
            $user = Get-ADUser -Identity $userSAM -ErrorAction SilentlyContinue
            if ($user) {
                Move-ADObject -Identity $user.DistinguishedName -TargetPath "OU=Demo_Users,$domainDN" -ErrorAction Stop
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
    Get-ADComputer -Filter {Name -like "CLIENT*" -or Name -like "*CLIENT*"} | ForEach-Object {
        try {
            Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Demo_Computers,$domainDN" -ErrorAction Stop
            Write-Host "[+] Moved computer: $($_.Name)" -ForegroundColor Green
        } catch {
            # Already in correct OU or move failed
        }
    }
} catch {
    Write-Host "[!] Warning: Could not move computers - $_" -ForegroundColor Yellow
}

Write-Host "[*] Moving CA servers..." -ForegroundColor Yellow
try {
    Get-ADComputer -Filter {Name -like "*XSIAM*" -and (Name -like "*CA*" -or Name -like "*AD01*")} | ForEach-Object {
        try {
            Move-ADObject -Identity $_.DistinguishedName -TargetPath "OU=Demo_Servers,$domainDN" -ErrorAction Stop
            Write-Host "[+] Moved server: $($_.Name)" -ForegroundColor Green
        } catch {
            # Already in correct OU or move failed
        }
    }
} catch {
    Write-Host "[!] Warning: Could not move servers - $_" -ForegroundColor Yellow
}
Write-Host ""

# ========================================
# SECTION 10: Enable Enhanced Logging
# ========================================
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

# ========================================
# SECTION 11: Configure Account Lockout Policy
# ========================================
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

# ========================================
# SECTION 12: Verification Summary
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Section 12: Configuration Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Verifying configuration..." -ForegroundColor Yellow

# Count users
$totalUsers = (Get-ADUser -Filter *).Count
$adminUsers = (Get-ADUser -Filter {SamAccountName -like "*admin*"}).Count
$serviceUsers = (Get-ADUser -Filter {SamAccountName -like "svc_*"}).Count
$nopreauthCount = (Get-ADUser -Filter * -Properties DoesNotRequirePreAuth | Where-Object {$_.DoesNotRequirePreAuth -eq $true}).Count
$spnCount = (Get-ADUser -Filter {ServicePrincipalName -like "*"} -Properties ServicePrincipalName).Count

Write-Host ""
Write-Host "=== CONFIGURATION SUMMARY ===" -ForegroundColor Yellow
Write-Host "Total Users: $totalUsers" -ForegroundColor Green
Write-Host "Administrative Accounts: $adminUsers" -ForegroundColor Green
Write-Host "Service Accounts: $serviceUsers" -ForegroundColor Green
Write-Host "AS-REP Roastable Accounts: $nopreauthCount" -ForegroundColor Green
Write-Host "Accounts with SPNs: $spnCount" -ForegroundColor Green
Write-Host ""

# Verify key accounts exist
$keyAccounts = @("insider", "targetuser", "da_admin", "svc_sql", "nopreauth1")

Write-Host "=== KEY ACCOUNTS ===" -ForegroundColor Yellow
foreach ($account in $keyAccounts) {
    $user = Get-ADUser -Identity $account -ErrorAction SilentlyContinue
    if ($user) {
        Write-Host "[✓] $account exists" -ForegroundColor Green
    } else {
        Write-Host "[✗] $account MISSING" -ForegroundColor Red
    }
}  # ← Closing brace for foreach loop

Write-Host ""
Write-Host "=== ORGANIZATIONAL UNITS ===" -ForegroundColor Yellow
try {
    $ous = Get-ADOrganizationalUnit -Filter 'Name -like "Demo_*"' -SearchBase $domainDN -ErrorAction SilentlyContinue
    if ($ous) {
        foreach ($ou in $ous) {
            $count = (Get-ADObject -Filter * -SearchBase $ou.DistinguishedName -SearchScope OneLevel -ErrorAction SilentlyContinue).Count
            Write-Host "[✓] $($ou.Name) - $count objects" -ForegroundColor Green
        }
    } else {
        Write-Host "[!] No Demo_* OUs found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[!] Error enumerating OUs - $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[+] All users created with password: $defaultPassword" -ForegroundColor Green
Write-Host "[+] All configurations applied" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Verify certificate template is configured (ESC1 vulnerability)" -ForegroundColor White
Write-Host "  2. Test insider account login: xsiam\\insider" -ForegroundColor White
Write-Host "  3. Verify SPNs are registered: setspn -Q */svc_sql" -ForegroundColor White
Write-Host "  4. Test AS-REP roasting on nopreauth1 account" -ForegroundColor White
Write-Host "  5. Create Pre-Attack snapshot" -ForegroundColor White
Write-Host ""