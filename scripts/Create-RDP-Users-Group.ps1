# Create-RDP-Users-Group.ps1
# Creates AD Security Group for Remote Desktop Users
# Adds domain users (insider, targetuser, standard users, IT admins) to the group
# Target: AD01 (172.31.4.65 / port 42425)

[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Platform Range - RDP Users Group Setup" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""

# Configuration
$groupName = "RDP_Users"
$groupDescription = "Domain users authorized for Remote Desktop access to workstations"
$domainDN = "DC=platform,DC=bakerstreetlabs,DC=io"

# Step 1: Check if group already exists
Write-ColorOutput "[1/3] Checking if RDP_Users group exists..." "Cyan"
$existingGroup = Get-ADGroup -Filter {SamAccountName -eq $groupName} -ErrorAction SilentlyContinue

if ($existingGroup) {
    Write-ColorOutput "    [!] Group already exists: $groupName" "Yellow"
    Write-ColorOutput "    Distinguished Name: $($existingGroup.DistinguishedName)" "Gray"
} else {
    # Create the group
    Write-ColorOutput "    [*] Creating new security group: $groupName" "Yellow"
    
    try {
        New-ADGroup `
            -Name $groupName `
            -SamAccountName $groupName `
            -GroupCategory Security `
            -GroupScope Global `
            -DisplayName "Remote Desktop Users" `
            -Path "CN=Users,$domainDN" `
            -Description $groupDescription `
            -ErrorAction Stop
        
        Write-ColorOutput "    [+] Group created successfully" "Green"
        
        # Verify creation
        $existingGroup = Get-ADGroup -Filter {SamAccountName -eq $groupName}
        Write-ColorOutput "    Distinguished Name: $($existingGroup.DistinguishedName)" "Gray"
    } catch {
        Write-ColorOutput "    [!] ERROR: Failed to create group - $_" "Red"
        exit 1
    }
}

Write-ColorOutput ""

# Step 2: Define users to add to the group
Write-ColorOutput "[2/3] Identifying users to add to RDP_Users..." "Cyan"

# Categories of users to include
$usersToAdd = @()

# Insider account (primary user for attack demos)
$insider = Get-ADUser -Filter {SamAccountName -eq "insider"} -ErrorAction SilentlyContinue
if ($insider) {
    $usersToAdd += $insider
    Write-ColorOutput "    [+] Found: insider" "Gray"
}

# Target user
$targetUser = Get-ADUser -Filter {SamAccountName -eq "targetuser"} -ErrorAction SilentlyContinue
if ($targetUser) {
    $usersToAdd += $targetUser
    Write-ColorOutput "    [+] Found: targetuser" "Gray"
}

# IT Admins
$itAdmins = Get-ADUser -Filter {SamAccountName -like "it_admin*"} -ErrorAction SilentlyContinue
foreach ($admin in $itAdmins) {
    $usersToAdd += $admin
    Write-ColorOutput "    [+] Found: $($admin.SamAccountName)" "Gray"
}

# Standard users (exclude service accounts, nopreauth accounts, and da_admin)
$standardUsers = Get-ADUser -Filter {
    (SamAccountName -notlike "svc_*") -and 
    (SamAccountName -notlike "nopreauth*") -and 
    (SamAccountName -ne "da_admin") -and
    (SamAccountName -ne "Administrator") -and
    (SamAccountName -ne "Guest") -and
    (SamAccountName -ne "krbtgt") -and
    (SamAccountName -ne "insider") -and
    (SamAccountName -ne "targetuser") -and
    (SamAccountName -notlike "it_admin*")
} -ErrorAction SilentlyContinue

foreach ($user in $standardUsers) {
    $usersToAdd += $user
    Write-ColorOutput "    [+] Found: $($user.SamAccountName)" "Gray"
}

Write-ColorOutput ""
Write-ColorOutput "    Total users to add: $($usersToAdd.Count)" "Cyan"
Write-ColorOutput ""

# Step 3: Add users to the group
Write-ColorOutput "[3/3] Adding users to RDP_Users group..." "Cyan"

$addedCount = 0
$skippedCount = 0
$errorCount = 0

foreach ($user in $usersToAdd) {
    # Check if already a member
    $isMember = Get-ADGroupMember -Identity $groupName -ErrorAction SilentlyContinue | 
        Where-Object {$_.SamAccountName -eq $user.SamAccountName}
    
    if ($isMember) {
        Write-ColorOutput "    [~] Already member: $($user.SamAccountName)" "DarkGray"
        $skippedCount++
    } else {
        try {
            Add-ADGroupMember -Identity $groupName -Members $user.SamAccountName -ErrorAction Stop
            Write-ColorOutput "    [+] Added: $($user.SamAccountName)" "Green"
            $addedCount++
        } catch {
            Write-ColorOutput "    [!] ERROR adding $($user.SamAccountName): $_" "Red"
            $errorCount++
        }
    }
}

Write-ColorOutput ""
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Summary" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "Group Name: $groupName" "White"
Write-ColorOutput "Group DN: $($existingGroup.DistinguishedName)" "White"
Write-ColorOutput ""
Write-ColorOutput "Users Added: $addedCount" "Green"
Write-ColorOutput "Already Members: $skippedCount" "Yellow"
Write-ColorOutput "Errors: $errorCount" "Red"
Write-ColorOutput ""

# Verify final membership
$members = Get-ADGroupMember -Identity $groupName | Select-Object Name, SamAccountName
Write-ColorOutput "Total Group Members: $($members.Count)" "Cyan"
Write-ColorOutput ""

if ($members.Count -gt 0) {
    Write-ColorOutput "Current Members:" "Cyan"
    $members | Sort-Object SamAccountName | ForEach-Object {
        Write-ColorOutput "  - $($_.SamAccountName) ($($_.Name))" "Gray"
    }
}

Write-ColorOutput ""
Write-ColorOutput "[+] RDP Users Group configuration complete!" "Green"
Write-ColorOutput ""
Write-ColorOutput "Next Step: Run Add-RDP-Group-ToClients.ps1 on each client" "Yellow"
Write-ColorOutput "  Or: Run Deploy-RDP-Access.ps1 to automate client configuration via SSH" "Yellow"
Write-ColorOutput ""

