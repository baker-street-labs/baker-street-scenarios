# Upload-AttackTools-AllClients.ps1
# Upload attack tools to all Platform Range clients via SCP
# Then remotely execute download script

[CmdletBinding()]
param(
    [string]$SSHKey = "C:\Users\richard\.ssh\id_rsa",
    [string]$LocalToolsPath = "E:\projects\tools",
    [string]$RemoteScriptsPath = "C:\Scripts\platform",
    [string]$RemoteToolsPath = "C:\Tools"
)

$ErrorActionPreference = "Continue"

# Client configuration
$clients = @(
    @{ Name = "client01"; IP = "192.168.255.254"; Port = 42429; User = "platform\administrator" }
    @{ Name = "client02"; IP = "192.168.255.254"; Port = 42430; User = "platform\administrator" }
    @{ Name = "client03"; IP = "192.168.255.254"; Port = 42431; User = "platform\administrator" }
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function SSH-Exec {
    param(
        [string]$Host,
        [int]$Port,
        [string]$User,
        [string]$Command
    )
    
    ssh -i $SSHKey -p $Port "$User@$Host" "$Command" 2>&1
}

function SCP-Upload {
    param(
        [string]$Host,
        [int]$Port,
        [string]$User,
        [string]$LocalFile,
        [string]$RemotePath
    )
    
    scp -i $SSHKey -P $Port "$LocalFile" "${User}@${Host}:${RemotePath}" 2>&1
}

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Platform Range - Deploy Attack Tools" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""

# Verify local script exists
$downloadScript = "E:\projects\baker-street-labs\scripts\platform\Download-AttackTools-Client.ps1"
if (-not (Test-Path $downloadScript)) {
    Write-ColorOutput "[!] ERROR: Download script not found: $downloadScript" "Red"
    exit 1
}

Write-ColorOutput "[*] Local download script: $downloadScript" "Cyan"
Write-ColorOutput ""

# Process each client
foreach ($client in $clients) {
    Write-ColorOutput "========================================" "Yellow"
    Write-ColorOutput "Processing: $($client.Name)" "Yellow"
    Write-ColorOutput "========================================" "Yellow"
    Write-ColorOutput ""
    
    # Step 1: Create C:\Tools directory
    Write-ColorOutput "[1/3] Creating C:\Tools directory on $($client.Name)..." "Cyan"
    $result = SSH-Exec -Host $client.IP -Port $client.Port -User $client.User -Command "powershell.exe -Command `"if (-not (Test-Path C:\Tools)) { New-Item -ItemType Directory -Path C:\Tools -Force | Out-Null; Write-Host 'Created' } else { Write-Host 'Exists' }`""
    Write-ColorOutput "    $result" "Gray"
    
    # Step 2: Upload download script
    Write-ColorOutput "[2/3] Uploading download script to $($client.Name)..." "Cyan"
    $uploadPath = "$RemoteScriptsPath\Download-AttackTools-Client.ps1"
    $result = SCP-Upload -Host $client.IP -Port $client.Port -User $client.User -LocalFile $downloadScript -RemotePath $uploadPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "    [+] Upload successful" "Green"
    } else {
        Write-ColorOutput "    [!] Upload failed: $result" "Red"
        continue
    }
    
    # Step 3: Execute download script remotely
    Write-ColorOutput "[3/3] Executing download script on $($client.Name)..." "Cyan"
    Write-ColorOutput "    This may take 30-60 seconds..." "Gray"
    
    $command = "powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\platform\Download-AttackTools-Client.ps1"
    $result = SSH-Exec -Host $client.IP -Port $client.Port -User $client.User -Command $command
    
    # Display output
    Write-ColorOutput ""
    Write-ColorOutput "--- Output from $($client.Name) ---" "DarkGray"
    $result | ForEach-Object { Write-ColorOutput $_ "Gray" }
    Write-ColorOutput "--- End Output ---" "DarkGray"
    Write-ColorOutput ""
    
    # Verify tools installed
    Write-ColorOutput "[*] Verifying installation on $($client.Name)..." "Cyan"
    $verifyCmd = "powershell.exe -Command `"Get-ChildItem C:\Tools\*.exe | Select-Object Name, @{N='SizeKB';E={[math]::Round(`$_.Length/1KB,2)}} | Format-Table -AutoSize`""
    $result = SSH-Exec -Host $client.IP -Port $client.Port -User $client.User -Command $verifyCmd
    
    if ($result -match "Certify.exe|Rubeus.exe") {
        Write-ColorOutput "[+] Tools verified on $($client.Name)" "Green"
        $result | ForEach-Object { Write-ColorOutput "    $_" "Gray" }
    } else {
        Write-ColorOutput "[!] WARNING: Tools may not have installed correctly on $($client.Name)" "Yellow"
        Write-ColorOutput "[!] Check output above for errors" "Yellow"
    }
    
    Write-ColorOutput ""
}

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Deployment Complete" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "If downloads were blocked by XDR/Antivirus:" "Yellow"
Write-ColorOutput "Option 1: Manually upload pre-downloaded tools" "Cyan"
Write-ColorOutput "  scp -i $SSHKey -P 42429 E:\tools\Certify.exe platform\administrator@192.168.255.254:C:\Tools\" "Gray"
Write-ColorOutput "  scp -i $SSHKey -P 42429 E:\tools\Rubeus.exe platform\administrator@192.168.255.254:C:\Tools\" "Gray"
Write-ColorOutput "  scp -i $SSHKey -P 42429 E:\tools\mimikatz.exe platform\administrator@192.168.255.254:C:\Tools\" "Gray"
Write-ColorOutput ""
Write-ColorOutput "Option 2: Disable Windows Defender on clients temporarily" "Cyan"
Write-ColorOutput "  ssh -i $SSHKey -p 42429 platform\administrator@192.168.255.254 'powershell.exe -Command `"Set-MpPreference -DisableRealtimeMonitoring \$true`"'" "Gray"
Write-ColorOutput ""
Write-ColorOutput "Next: Proceed with ESC1 attack flow (docs/plans/3_platform_Attack_Flow.md)" "Green"
Write-ColorOutput ""

