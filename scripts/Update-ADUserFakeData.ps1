#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
    Audits, creates, and populates Active Directory user accounts with themed fake data for cyber ranges.
    
.DESCRIPTION
    This script supports three modes:
    1. Audit: Checks which required users exist vs defined in JSON
    2. CreateMissing: Creates users that don't exist based on JSON definitions
    3. Populate: Updates user attributes with themed data from JSON
    
    All data is clearly fictional and designed for academic/cyber range training environments.
    Uses Sherlock Holmes theme by default (configurable via JSON).
    
.PARAMETER Mode
    Operation mode: Audit, CreateMissing, Populate, or All (default: All)
    
.PARAMETER DomainDN
    Distinguished name of the domain. Default: "DC=platform,DC=bakerstreetlabs,DC=io"
    
.PARAMETER JsonPath
    Path to user-data.json file. Default: .\user-data.json in script directory
    
.EXAMPLE
    .\Update-ADUserFakeData.ps1 -Mode Audit
    
.EXAMPLE
    .\Update-ADUserFakeData.ps1 -Mode CreateMissing
    
.EXAMPLE
    .\Update-ADUserFakeData.ps1 -Mode Populate
    
.EXAMPLE
    .\Update-ADUserFakeData.ps1 -Mode All -WhatIf
    
.NOTES
    Version: 2.0
    Domain: platform.bakerstreetlabs.io
    Purpose: Cyber Range / Academic Training
    Author: Baker Street Labs
    Created: 2025-01-27
    Updated: 2025-01-27 - Added modular modes and JSON support
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Audit", "CreateMissing", "Populate", "All")]
    [string]$Mode = "All",
    
    [Parameter(Mandatory=$false)]
    [string]$DomainDN = "DC=platform,DC=bakerstreetlabs,DC=io",
    
    [Parameter(Mandatory=$false)]
    [string]$JsonPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$DefaultPassword = "Cortex1!"
)

# Import Active Directory module
if (-not (Get-Module -Name ActiveDirectory)) {
    try {
        Import-Module ActiveDirectory -ErrorAction Stop
    } catch {
        Write-Error "Failed to import ActiveDirectory module. Ensure RSAT-AD-PowerShell is installed." -ErrorAction Stop
        exit 1
    }
}

# Verify domain connectivity
try {
    $domainInfo = Get-ADDomain -ErrorAction Stop
    $domainName = $domainInfo.DNSRoot
    $domainDN = $domainInfo.DistinguishedName
} catch {
    Write-Error "Cannot connect to Active Directory domain. Ensure you are domain-joined and have appropriate permissions." -ErrorAction Stop
    exit 1
}

# Color output function
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Load JSON configuration
function Get-UserDataConfig {
    param([string]$Path)
    
    if ([string]::IsNullOrEmpty($Path)) {
        $scriptDir = Split-Path -Parent $MyInvocation.PSCommandPath
        $Path = Join-Path $scriptDir "user-data.json"
    }
    
    if (-not (Test-Path $Path)) {
        Write-Error "JSON file not found: $Path" -ErrorAction Stop
        exit 1
    }
    
    try {
        $jsonContent = Get-Content $Path -Raw | ConvertFrom-Json
        return $jsonContent
    } catch {
        Write-Error "Failed to parse JSON file: $($_.Exception.Message)" -ErrorAction Stop
        exit 1
    }
}

# Replace placeholders in strings (e.g., {domain}, {sam})
function Expand-Placeholders {
    param(
        [string]$Template,
        [string]$Domain,
        [string]$SamAccountName = ""
    )
    
    $result = $Template
    $result = $result -replace '\{domain\}', $Domain
    $result = $result -replace '\{sam\}', $SamAccountName
    return $result
}

# Get random item from array
function Get-RandomItem {
    param([array]$Items)
    if ($Items -and $Items.Length -gt 0) {
        return $Items[(Get-Random -Minimum 0 -Maximum $Items.Length)]
    }
    return $null
}

# Generate fake phone number
function Get-FakePhoneNumber {
    $areaCode = Get-Random -Minimum 200 -Maximum 900
    $exchange = "555"
    $number = Get-Random -Minimum 1000 -Maximum 9999
    return "$areaCode-555-$number"
}

# Audit users - check which users exist
function Audit-ADUsers {
    param(
        [object]$Config,
        [string]$DomainName
    )
    
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "AUDIT MODE - User Existence Check" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    Write-Host ""
    
    $allUsers = @()
    $missingUsers = @()
    $existingUsers = @()
    
    # Collect all user SAMs from JSON
    foreach ($category in @("admins", "service", "standard", "roastable", "insider", "target")) {
        if ($Config.users.$category) {
            foreach ($userDef in $Config.users.$category) {
                if (-not $userDef.optional -or $userDef.optional -eq $false) {
                    $allUsers += $userDef.sam
                }
            }
        }
    }
    
    Write-ColorOutput "[*] Checking $($allUsers.Count) required users..." "Yellow"
    Write-Host ""
    
    foreach ($sam in $allUsers) {
        try {
            $user = Get-ADUser -Identity $sam -ErrorAction Stop
            $existingUsers += $sam
            Write-ColorOutput "  [+] EXISTS: $sam" "Green"
        } catch {
            $missingUsers += $sam
            Write-ColorOutput "  [-] MISSING: $sam" "Red"
        }
    }
    
    Write-Host ""
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "AUDIT SUMMARY" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "Total Required: $($allUsers.Count)" "White"
    Write-ColorOutput "Existing: $($existingUsers.Count)" "Green"
    Write-ColorOutput "Missing: $($missingUsers.Count)" $(if ($missingUsers.Count -eq 0) { "Green" } else { "Red" })
    Write-Host ""
    
    return @{
        AllUsers = $allUsers
        ExistingUsers = $existingUsers
        MissingUsers = $missingUsers
    }
}

# Create OU structure for cyber range domain
function Create-OUStructure {
    param(
        [string]$DomainDN
    )
    
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "Creating Organizational Unit Structure" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    Write-Host ""
    
    # Define OU structure for cyber range domains
    $ouStructure = @{
        "Admins" = "Administrator accounts"
        "ServiceAccounts" = "Service accounts"
        "Users" = "Standard users and other accounts"
    }
    
    $created = 0
    $skipped = 0
    
    foreach ($ouName in $ouStructure.Keys) {
        $ouPath = $DomainDN
        $ouDN = "OU=$ouName,$ouPath"
        $description = $ouStructure[$ouName]
        
        # Check if OU exists
        $existingOU = $null
        try {
            $existingOU = Get-ADOrganizationalUnit -Identity $ouDN -ErrorAction Stop
        } catch {
            $existingOU = $null
        }
        
        if ($existingOU) {
            Write-ColorOutput "  [~] EXISTS: $ouDN" "Yellow"
            $skipped++
        } else {
            try {
                New-ADOrganizationalUnit -Name $ouName -Path $ouPath -Description $description -ErrorAction Stop
                Write-ColorOutput "  [+] CREATED: $ouDN" "Green"
                $created++
            } catch {
                Write-ColorOutput "  [!] ERROR creating $ouDN : $($_.Exception.Message)" "Red"
            }
        }
    }
    
    Write-Host ""
    Write-ColorOutput "OU Structure Summary: Created $created, Skipped $skipped" "Cyan"
    Write-Host ""
}

# Create missing users from JSON
function Create-MissingADUsers {
    param(
        [object]$Config,
        [string]$DomainName,
        [string]$DomainDN,
        [string]$DefaultPassword = "Cortex1!"
    )
    
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "CREATE MODE - Creating Missing Users" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    Write-Host ""
    
    $created = 0
    $errors = 0
    
    # Process each category
    foreach ($category in @("admins", "service", "standard", "roastable", "insider", "target")) {
        if (-not $Config.users.$category) { continue }
        
        Write-ColorOutput "[*] Processing $category users..." "Yellow"
        
        foreach ($userDef in $Config.users.$category) {
            # Skip optional users
            if ($userDef.optional -and $userDef.optional -eq $true) {
                Write-ColorOutput "  [~] SKIPPING (optional): $($userDef.sam)" "Gray"
                continue
            }
            
            # Check if user exists (reliably - use try-catch to completely suppress error output)
            $existingUser = $null
            try {
                $existingUser = Get-ADUser -Identity $userDef.sam -ErrorAction Stop
            } catch {
                # User doesn't exist - this is expected, suppress error completely
                $existingUser = $null
            }
            
            if ($existingUser) {
                Write-ColorOutput "  [~] EXISTS: $($userDef.sam)" "Yellow"
                continue
            }
            
            # User doesn't exist - proceed with creation
            try {
                # Parse name
                $nameParts = $userDef.name -split ' ', 2
                $givenName = if ($nameParts.Length -gt 0) { $nameParts[0] } else { $userDef.name }
                $surname = if ($nameParts.Length -gt 1) { $nameParts[1] } else { "" }
                
                # Create UPN
                $upn = Expand-Placeholders -Template "$($userDef.sam)@$DomainName" -Domain $DomainName -SamAccountName $userDef.sam
                
                # Determine OU path based on user category
                $ouPath = switch ($category) {
                    "admins" { "OU=Admins,$DomainDN" }
                    "service" { "OU=ServiceAccounts,$DomainDN" }
                    default { "OU=Users,$DomainDN" }
                }
                
                # Verify OU exists, create if it doesn't
                $ouExists = $null
                try {
                    $ouExists = Get-ADOrganizationalUnit -Identity $ouPath -ErrorAction Stop
                } catch {
                    $ouExists = $null
                }
                
                if (-not $ouExists) {
                    # Create the OU if it doesn't exist
                    try {
                        $ouName = ($ouPath -split ',')[0] -replace 'OU=',''
                        New-ADOrganizationalUnit -Name $ouName -Path $DomainDN -ErrorAction Stop
                        Write-ColorOutput "    [+] Created OU: $ouPath" "Gray"
                    } catch {
                        Write-ColorOutput "    [!] Failed to create OU $ouPath, using domain root" "Yellow"
                        $ouPath = $DomainDN
                    }
                }
                
                # Use default lab password for new user creation (always use DefaultPassword for missing users)
                $password = $DefaultPassword
                
                # Build user params
                $userParams = @{
                    Name = $userDef.name
                    SamAccountName = $userDef.sam
                    UserPrincipalName = $upn
                    DisplayName = $userDef.name
                    Path = $ouPath
                    AccountPassword = (ConvertTo-SecureString $password -AsPlainText -Force)
                    Enabled = $true
                    PasswordNeverExpires = $true
                    ChangePasswordAtLogon = $false
                }
                
                if ($givenName) { $userParams.GivenName = $givenName }
                if ($surname) { $userParams.Surname = $surname }
                if ($userDef.description) { $userParams.Description = $userDef.description }
                
                # Create user
                if ($PSCmdlet.ShouldProcess($userDef.sam, "Create AD user")) {
                    if (-not $WhatIfPreference) {
                        try {
                            # Attempt to create the user
                            New-ADUser @userParams -ErrorAction Stop
                            Write-ColorOutput "  [+] CREATED: $($userDef.sam)" "Green"
                            
                            # Wait briefly for AD replication
                            Start-Sleep -Milliseconds 500
                            
                            # Verify user exists before post-creation operations (suppress errors)
                            $verifyUser = $null
                            try {
                                $verifyUser = Get-ADUser -Identity $userDef.sam -ErrorAction Stop
                            } catch {
                                $verifyUser = $null
                            }
                            if (-not $verifyUser) {
                                Write-ColorOutput "    [!] Warning: User created but not immediately available, skipping post-creation operations" "Yellow"
                                $created++
                                continue
                            }
                            
                            # Add to groups if specified
                            if ($userDef.groups) {
                                foreach ($group in $userDef.groups) {
                                    try {
                                        Add-ADGroupMember -Identity $group -Members $userDef.sam -ErrorAction Stop
                                        Write-ColorOutput "    [+] Added to group: $group" "Gray"
                                    } catch {
                                        Write-ColorOutput "    [!] Failed to add to group $group : $($_.Exception.Message)" "Yellow"
                                        # Don't fail user creation if group add fails
                                    }
                                }
                            }
                            
                            # Register SPNs for service accounts
                            if ($userDef.spn) {
                                foreach ($spnTemplate in $userDef.spn) {
                                    $spn = Expand-Placeholders -Template $spnTemplate -Domain $DomainName -SamAccountName $userDef.sam
                                    try {
                                        setspn -A $spn "$($DomainName.Split('.')[0])\$($userDef.sam)" 2>&1 | Out-Null
                                        Write-ColorOutput "    [+] Registered SPN: $spn" "Gray"
                                    } catch {
                                        Write-ColorOutput "    [!] Failed to register SPN $spn : $($_.Exception.Message)" "Yellow"
                                        # Don't fail user creation if SPN registration fails
                                    }
                                }
                            }
                            
                            # Configure AS-REP roasting if needed
                            if ($userDef.preauth -eq $false) {
                                try {
                                    Set-ADAccountControl -Identity $userDef.sam -DoesNotRequirePreAuth $true -ErrorAction Stop
                                    Write-ColorOutput "    [+] AS-REP roasting enabled" "Gray"
                                } catch {
                                    Write-ColorOutput "    [!] Failed to enable AS-REP roasting: $($_.Exception.Message)" "Yellow"
                                    # Don't fail user creation if AS-REP config fails
                                }
                            }
                            
                            $created++
                        } catch {
                            # If New-ADUser fails, show error
                            Write-ColorOutput "  [!] ERROR creating $($userDef.sam): $($_.Exception.Message)" "Red"
                            $errors++
                        }
                    } else {
                        Write-ColorOutput "  [WHATIF] Would create: $($userDef.sam)" "Yellow"
                        # Increment counter when ShouldProcess confirms (works in both WhatIf and actual execution)
                        $created++
                    }
                }
            } catch {
                Write-ColorOutput "  [!] ERROR creating $($userDef.sam): $($_.Exception.Message)" "Red"
                $errors++
            }
        }
        Write-Host ""
    }
    
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "CREATE SUMMARY" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    if ($WhatIfPreference) {
        Write-ColorOutput "Would create: $created users" "Yellow"
    } else {
        Write-ColorOutput "Created: $created users" "Green"
        Write-ColorOutput "Errors: $errors users" $(if ($errors -eq 0) { "Green" } else { "Red" })
    }
    Write-Host ""
    
    return @{ Created = $created; Errors = $errors }
}

# Populate user attributes with themed data
function Populate-ADUserData {
    param(
        [object]$Config,
        [string]$DomainName
    )
    
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "POPULATE MODE - Updating User Attributes" "Cyan"
    Write-ColorOutput "Theme: $($Config.theme)" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    Write-Host ""
    
    # Get all enabled users (excluding built-in)
    Write-ColorOutput "[*] Retrieving AD users..." "Yellow"
    try {
        $users = Get-ADUser -Filter {
            Enabled -eq $true -and 
            SamAccountName -notlike "Administrator" -and
            SamAccountName -notlike "Guest" -and
            SamAccountName -notlike "krbtgt" -and
            SamAccountName -notlike "DefaultAccount"
        } -Properties DisplayName, Title, Department, OfficePhone, MobilePhone, StreetAddress, City, State, PostalCode, Office, Company, Country, Description
        
        if (-not $users) {
            Write-ColorOutput "[!] No users found to update." "Red"
            return
        }
        
        Write-ColorOutput "[+] Found $($users.Count) users to process" "Green"
        Write-Host ""
    } catch {
        Write-ColorOutput "[!] Error retrieving users: $($_.Exception.Message)" "Red"
        return
    }
    
    $successCount = 0
    $errorCount = 0
    $totalUsers = $users.Count
    $currentUser = 0
    
    foreach ($user in $users) {
        $currentUser++
        try {
            $isServiceAccount = $user.SamAccountName -like "svc_*"
            $accountType = if ($isServiceAccount) { "Service Account" } else { "User Account" }
            
            Write-ColorOutput "[*] Processing [$currentUser/$totalUsers]: $($user.SamAccountName) ($($user.DisplayName)) [$accountType]" "Cyan"
            
            # Build fake data based on account type
            if ($isServiceAccount) {
                # Service accounts: minimal data
                $fakeData = @{
                    Title = "Service Account"
                    Department = Get-RandomItem -Items $Config.fakeDepartments
                    OfficePhone = ""
                    MobilePhone = ""
                    StreetAddress = ""
                    City = ""
                    State = ""
                    PostalCode = ""
                    Office = Get-RandomItem -Items $Config.fakeServiceOffices
                    Company = $Config.fakeCompany
                    Country = ""
                    Description = $user.Description  # Keep existing description
                }
            } else {
                # Regular users: full themed data
                $fakeData = @{
                    Title = Get-RandomItem -Items $Config.fakeJobTitles
                    Department = Get-RandomItem -Items $Config.fakeDepartments
                    OfficePhone = Get-FakePhoneNumber
                    MobilePhone = Get-FakePhoneNumber
                    StreetAddress = Get-RandomItem -Items $Config.fakeStreetAddresses
                    City = Get-RandomItem -Items $Config.fakeCities
                    State = Get-RandomItem -Items $Config.fakeStates
                    PostalCode = Get-RandomItem -Items $Config.fakeZipCodes
                    Office = Get-RandomItem -Items $Config.fakeOffices
                    Company = $Config.fakeCompany
                    Country = "GB"
                    Description = ""
                }
            }
            
            # Count this user
            $successCount++
            
            if ($PSCmdlet.ShouldProcess($user.SamAccountName, "Update with themed fake data")) {
                if ($WhatIfPreference) {
                    Write-Host "  Would update:" -ForegroundColor Yellow
                    Write-Host "    Title: $($fakeData.Title)"
                    Write-Host "    Department: $($fakeData.Department)"
                    if ($fakeData.OfficePhone) { Write-Host "    Office Phone: $($fakeData.OfficePhone)" }
                    if ($fakeData.MobilePhone) { Write-Host "    Mobile Phone: $($fakeData.MobilePhone)" }
                    if ($fakeData.StreetAddress) { Write-Host "    Address: $($fakeData.StreetAddress), $($fakeData.City), $($fakeData.State) $($fakeData.PostalCode)" }
                    Write-Host "    Office: $($fakeData.Office)"
                    Write-Host "    Company: $($fakeData.Company)"
                } else {
                    # Build update parameters
                    $updateParams = @{
                        Identity = $user.SamAccountName
                        Title = $fakeData.Title
                        Department = $fakeData.Department
                        Office = $fakeData.Office
                        Company = $fakeData.Company
                        ErrorAction = "Stop"
                    }
                    
                    # Add optional fields for regular users only
                    if (-not $isServiceAccount) {
                        if ($fakeData.OfficePhone) { $updateParams.OfficePhone = $fakeData.OfficePhone }
                        if ($fakeData.MobilePhone) { $updateParams.MobilePhone = $fakeData.MobilePhone }
                        if ($fakeData.StreetAddress) { $updateParams.StreetAddress = $fakeData.StreetAddress }
                        if ($fakeData.City) { $updateParams.City = $fakeData.City }
                        if ($fakeData.State) { $updateParams.State = $fakeData.State }
                        if ($fakeData.PostalCode) { $updateParams.PostalCode = $fakeData.PostalCode }
                        if ($fakeData.Country) { $updateParams.Country = $fakeData.Country }
                    }
                    
                    Set-ADUser @updateParams
                    Write-ColorOutput "  [+] Updated successfully" "Green"
                }
            }
            Write-Host ""
        } catch {
            Write-ColorOutput "  [!] Error updating user: $($_.Exception.Message)" "Red"
            if ($_.Exception.InnerException) {
                Write-ColorOutput "  [!] Inner exception: $($_.Exception.InnerException.Message)" "Red"
            }
            $errorCount++
            $successCount--
            Write-Host ""
        }
    }
    
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "POPULATE SUMMARY" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    
    if ($WhatIfPreference) {
        Write-ColorOutput "[WHATIF] Would update: $successCount users" "Yellow"
    } else {
        Write-ColorOutput "Successfully updated: $successCount users" "Green"
        Write-ColorOutput "Errors: $errorCount users" $(if ($errorCount -eq 0) { "Green" } else { "Red" })
    }
    Write-Host ""
}

# Main execution
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "AD User Management Script" "Cyan"
Write-ColorOutput "Domain: $domainName" "Cyan"
Write-ColorOutput "Mode: $Mode" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-Host ""

# Load JSON configuration
$config = Get-UserDataConfig -Path $JsonPath

# Execute based on mode
switch ($Mode) {
    "Audit" {
        $auditResult = Audit-ADUsers -Config $config -DomainName $domainName
    }
    "CreateMissing" {
        $createResult = Create-MissingADUsers -Config $config -DomainName $domainName -DomainDN $domainDN -DefaultPassword $DefaultPassword
    }
    "Populate" {
        Populate-ADUserData -Config $config -DomainName $domainName
    }
    "All" {
        Write-ColorOutput "[*] Running in All mode (OU Structure -> Audit -> CreateMissing -> Populate)" "Yellow"
        Write-Host ""
        
        # Step 0: Create OU structure
        Create-OUStructure -DomainDN $domainDN
        
        # Step 1: Audit
        $auditResult = Audit-ADUsers -Config $config -DomainName $domainName
        
        # Step 2: Create missing users
        if ($auditResult.MissingUsers.Count -gt 0) {
            Write-Host ""
            $createResult = Create-MissingADUsers -Config $config -DomainName $domainName -DomainDN $domainDN -DefaultPassword $DefaultPassword
        } else {
            Write-ColorOutput "[*] No missing users - skipping creation" "Yellow"
            Write-Host ""
        }
        
        # Step 3: Populate
        Write-Host ""
        Populate-ADUserData -Config $config -DomainName $domainName
    }
    "CreateMissing" {
        # Create OU structure first before creating users
        Create-OUStructure -DomainDN $domainDN
        Write-Host ""
        $createResult = Create-MissingADUsers -Config $config -DomainName $domainName -DomainDN $domainDN -DefaultPassword $DefaultPassword
    }
}

Write-ColorOutput "[+] Script execution complete!" "Green"
Write-ColorOutput "[*] All data is clearly fictional for cyber range use." "Yellow"
Write-Host ""
