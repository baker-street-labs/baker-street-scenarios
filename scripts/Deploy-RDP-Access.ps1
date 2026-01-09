# Deploy-RDP-Access.ps1
# Orchestrates RDP access configuration for Platform Range
# 1. Creates AD group on AD01
# 2. Adds domain users to the group
# 3. Configures all clients to allow RDP access for the group

[CmdletBinding()]
param(
    [string]$SSHKey = "C:\Users\richard\.ssh\id_rsa"
)

$ErrorActionPreference = "Continue"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function SSH-Exec {
    param([string]$Server, [int]$Port, [string]$User, [string]$Command)
    ssh -i $SSHKey -p $Port "$User@$Server" "$Command" 2>&1
}

function SCP-Upload {
    param([string]$Server, [int]$Port, [string]$User, [string]$LocalFile, [string]$RemotePath)
    scp -i $SSHKey -P $Port "$LocalFile" "${User}@${Server}:${RemotePath}" 2>&1
}

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Platform Range - Deploy RDP Access" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""

# Configuration
$ad01 = @{ IP = "192.168.255.254"; Port = 42425; User = "platform\administrator" }
$clients = @(
    @{ Name = "client01"; IP = "192.168.255.254"; Port = 42429; User = "platform\administrator" }
    @{ Name = "client02"; IP = "192.168.255.254"; Port = 42430; User = "platform\administrator" }
    @{ Name = "client03"; IP = "192.168.255.254"; Port = 42431; User = "platform\administrator" }
)

$scriptPath = "E:\projects\baker-street-labs\scripts\platform"

# ============================================================================
# PHASE 1: Create AD Group on AD01
# ============================================================================

Write-ColorOutput "========================================" "Yellow"
Write-ColorOutput "PHASE 1: Configure Active Directory" "Yellow"
Write-ColorOutput "========================================" "Yellow"
Write-ColorOutput ""

Write-ColorOutput "[*] Uploading AD group creation script to AD01..." "Cyan"
$adScript = Join-Path $scriptPath "Create-RDP-Users-Group.ps1"

if (-not (Test-Path $adScript)) {
    Write-ColorOutput "[!] ERROR: Script not found: $adScript" "Red"
    exit 1
}

$uploadResult = SCP-Upload -Server $ad01.IP -Port $ad01.Port -User $ad01.User `
    -LocalFile $adScript -RemotePath "C:\Scripts\platform\Create-RDP-Users-Group.ps1"

if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "[+] Upload successful" "Green"
} else {
    Write-ColorOutput "[!] Upload failed: $uploadResult" "Red"
    exit 1
}

Write-ColorOutput ""
Write-ColorOutput "[*] Executing AD group creation on AD01..." "Cyan"
Write-ColorOutput "    This may take 30-60 seconds..." "Gray"
Write-ColorOutput ""

$command = "powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\platform\Create-RDP-Users-Group.ps1"
$result = SSH-Exec -Server $ad01.IP -Port $ad01.Port -User $ad01.User -Command $command

# Display output
$result | ForEach-Object { Write-ColorOutput $_ "Gray" }

if ($result -match "RDP Users Group configuration complete") {
    Write-ColorOutput ""
    Write-ColorOutput "[+] AD configuration successful" "Green"
} else {
    Write-ColorOutput ""
    Write-ColorOutput "[!] WARNING: AD configuration may have failed - check output above" "Yellow"
}

Write-ColorOutput ""

# ============================================================================
# PHASE 2: Configure Clients
# ============================================================================

Write-ColorOutput "========================================" "Yellow"
Write-ColorOutput "PHASE 2: Configure Client Workstations" "Yellow"
Write-ColorOutput "========================================" "Yellow"
Write-ColorOutput ""

$clientScript = Join-Path $scriptPath "Add-RDP-Group-ToClients.ps1"

if (-not (Test-Path $clientScript)) {
    Write-ColorOutput "[!] ERROR: Script not found: $clientScript" "Red"
    exit 1
}

foreach ($client in $clients) {
    Write-ColorOutput "--- Configuring: $($client.Name) ---" "Yellow"
    Write-ColorOutput ""
    
    # Upload script
    Write-ColorOutput "[1/2] Uploading script to $($client.Name)..." "Cyan"
    $uploadResult = SCP-Upload -Server $client.IP -Port $client.Port -User $client.User `
        -LocalFile $clientScript -RemotePath "C:\Scripts\platform\Add-RDP-Group-ToClients.ps1"
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "    [+] Upload successful" "Green"
    } else {
        Write-ColorOutput "    [!] Upload failed: $uploadResult" "Red"
        continue
    }
    
    # Execute script
    Write-ColorOutput "[2/2] Executing configuration on $($client.Name)..." "Cyan"
    $command = "powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\platform\Add-RDP-Group-ToClients.ps1"
    $result = SSH-Exec -Server $client.IP -Port $client.Port -User $client.User -Command $command
    
    # Display output (filtered for readability)
    Write-ColorOutput ""
    $result | ForEach-Object { Write-ColorOutput "    $_" "Gray" }
    
    if ($result -match "SUCCESS: Domain RDP_Users group is member") {
        Write-ColorOutput ""
        Write-ColorOutput "    [+] $($client.Name) configured successfully" "Green"
    } else {
        Write-ColorOutput ""
        Write-ColorOutput "    [!] WARNING: Configuration may have failed - check output above" "Yellow"
    }
    
    Write-ColorOutput ""
}

# ============================================================================
# PHASE 3: Verification
# ============================================================================

Write-ColorOutput "========================================" "Yellow"
Write-ColorOutput "PHASE 3: Final Verification" "Yellow"
Write-ColorOutput "========================================" "Yellow"
Write-ColorOutput ""

Write-ColorOutput "[*] Verifying AD group membership on AD01..." "Cyan"
$verifyCmd = "powershell.exe -Command `"Get-ADGroupMember -Identity RDP_Users | Select-Object Name, SamAccountName | Format-Table -AutoSize`""
$result = SSH-Exec -Server $ad01.IP -Port $ad01.Port -User $ad01.User -Command $verifyCmd

Write-ColorOutput ""
Write-ColorOutput "RDP_Users Group Members:" "Cyan"
$result | ForEach-Object { Write-ColorOutput "  $_" "Gray" }
Write-ColorOutput ""

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Deployment Complete!" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "[+] RDP access configured for domain users" "Green"
Write-ColorOutput "[+] Group: PLATFORM\RDP_Users" "Green"
Write-ColorOutput "[+] Configured on: client01, client02, client03" "Green"
Write-ColorOutput ""
Write-ColorOutput "Testing:" "Yellow"
Write-ColorOutput "1. RDP to any client via Guacamole as platform\insider" "White"
Write-ColorOutput "2. Verify connection succeeds" "White"
Write-ColorOutput "3. Proceed with ESC1 attack flow" "White"
Write-ColorOutput ""
Write-ColorOutput "If RDP fails:" "Yellow"
Write-ColorOutput "- Verify Guacamole connection uses 'platform\insider' (not Administrator)" "White"
Write-ColorOutput "- Check client firewall allows RDP (port 3389)" "White"
Write-ColorOutput "- Verify domain connectivity from client" "White"
Write-ColorOutput ""

