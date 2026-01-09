# Add-RDP-Group-ToClients.ps1
# Adds domain group "PLATFORM\RDP_Users" to local "Remote Desktop Users" group
# Target: CLIENT01, CLIENT02, CLIENT03 (run on each client)

[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Add RDP Group to Local Remote Desktop Users" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""

# Configuration
$domainGroup = "PLATFORM\RDP_Users"
$localGroup = "Remote Desktop Users"

# Step 1: Verify local group exists
Write-ColorOutput "[1/3] Verifying local group exists..." "Cyan"
try {
    $rdpGroup = Get-LocalGroup -Name $localGroup -ErrorAction Stop
    Write-ColorOutput "    [+] Found local group: $localGroup" "Green"
} catch {
    Write-ColorOutput "    [!] ERROR: Local group '$localGroup' not found" "Red"
    Write-ColorOutput "    This should exist on all Windows systems. Verify OS installation." "Yellow"
    exit 1
}

Write-ColorOutput ""

# Step 2: Check if domain group is already a member
Write-ColorOutput "[2/3] Checking current membership..." "Cyan"
try {
    $currentMembers = Get-LocalGroupMember -Group $localGroup -ErrorAction Stop
    $domainGroupMember = $currentMembers | Where-Object {$_.Name -like "*RDP_Users*"}
    
    if ($domainGroupMember) {
        Write-ColorOutput "    [~] Domain group already member: $($domainGroupMember.Name)" "Yellow"
        Write-ColorOutput "    No changes needed." "Yellow"
        $alreadyMember = $true
    } else {
        Write-ColorOutput "    [*] Domain group not currently a member" "Gray"
        $alreadyMember = $false
    }
} catch {
    Write-ColorOutput "    [!] WARNING: Could not enumerate members - $_" "Yellow"
    $alreadyMember = $false
}

Write-ColorOutput ""

# Step 3: Add domain group to local RDP group
if (-not $alreadyMember) {
    Write-ColorOutput "[3/3] Adding domain group to local RDP group..." "Cyan"
    
    try {
        # Try adding the domain group
        Add-LocalGroupMember -Group $localGroup -Member $domainGroup -ErrorAction Stop
        Write-ColorOutput "    [+] Successfully added $domainGroup to $localGroup" "Green"
        $success = $true
    } catch {
        # If failed, try alternative domain formats
        Write-ColorOutput "    [!] Failed with PLATFORM\RDP_Users format" "Yellow"
        Write-ColorOutput "    [*] Trying alternative format: platform.bakerstreetlabs.io\RDP_Users" "Yellow"
        
        try {
            Add-LocalGroupMember -Group $localGroup -Member "platform.bakerstreetlabs.io\RDP_Users" -ErrorAction Stop
            Write-ColorOutput "    [+] Successfully added with FQDN format" "Green"
            $success = $true
        } catch {
            Write-ColorOutput "    [!] ERROR: Failed to add domain group - $_" "Red"
            Write-ColorOutput "    Possible causes:" "Yellow"
            Write-ColorOutput "      - Domain group RDP_Users does not exist" "Yellow"
            Write-ColorOutput "      - Client cannot contact domain controller" "Yellow"
            Write-ColorOutput "      - Insufficient permissions" "Yellow"
            $success = $false
        }
    }
} else {
    Write-ColorOutput "[3/3] Skipping - already configured" "Yellow"
    $success = $true
}

Write-ColorOutput ""

# Step 4: Verify final configuration
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Verification" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""

try {
    $finalMembers = Get-LocalGroupMember -Group $localGroup -ErrorAction Stop
    Write-ColorOutput "Current members of '$localGroup':" "Cyan"
    
    foreach ($member in $finalMembers) {
        $memberType = $member.ObjectClass
        $prefix = if ($member.Name -like "*RDP_Users*") { "[RDP GROUP]" } else { "           " }
        Write-ColorOutput "  $prefix $($member.Name) ($memberType)" "Gray"
    }
    
    Write-ColorOutput ""
    
    # Check if RDP_Users is present
    $rdpGroupPresent = $finalMembers | Where-Object {$_.Name -like "*RDP_Users*"}
    if ($rdpGroupPresent) {
        Write-ColorOutput "[+] SUCCESS: Domain RDP_Users group is member of local RDP group" "Green"
        Write-ColorOutput ""
        Write-ColorOutput "Users in PLATFORM\RDP_Users can now connect via Remote Desktop" "Green"
    } else {
        Write-ColorOutput "[!] WARNING: Domain RDP_Users group NOT found in local group" "Red"
        Write-ColorOutput "    RDP access may not work for domain users" "Yellow"
    }
} catch {
    Write-ColorOutput "[!] ERROR verifying membership: $_" "Red"
}

Write-ColorOutput ""
Write-ColorOutput "Configuration complete!" "Cyan"
Write-ColorOutput ""

