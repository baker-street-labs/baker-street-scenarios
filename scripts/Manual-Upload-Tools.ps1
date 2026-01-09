# Manual-Upload-Tools.ps1
# Manually upload pre-downloaded attack tools to Platform Range clients
# Use this if download script is blocked by XDR/Antivirus

[CmdletBinding()]
param(
    [string]$SSHKey = "C:\Users\richard\.ssh\id_rsa",
    [string]$LocalToolsPath = "E:\projects\tools"
)

$ErrorActionPreference = "Continue"

# Client configuration
$clients = @(
    @{ Name = "client01"; IP = "192.168.255.254"; Port = 42429; User = "platform\administrator" }
    @{ Name = "client02"; IP = "192.168.255.254"; Port = 42430; User = "platform\administrator" }
    @{ Name = "client03"; IP = "192.168.255.254"; Port = 42431; User = "platform\administrator" }
)

# Tools to upload
$tools = @("Certify.exe", "Rubeus.exe", "mimikatz.exe")

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function SSH-Exec {
    param([string]$Host, [int]$Port, [string]$User, [string]$Command)
    ssh -i $SSHKey -p $Port "$User@$Host" "$Command" 2>&1
}

function SCP-Upload {
    param([string]$Host, [int]$Port, [string]$User, [string]$LocalFile, [string]$RemotePath)
    scp -i $SSHKey -P $Port "$LocalFile" "${User}@${Host}:${RemotePath}" 2>&1
}

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Manual Tool Upload - Platform Range" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""

# Verify local tools exist
Write-ColorOutput "[*] Verifying local tools in: $LocalToolsPath" "Cyan"
$missingTools = @()
foreach ($tool in $tools) {
    $fullPath = Join-Path $LocalToolsPath $tool
    if (Test-Path $fullPath) {
        $size = [math]::Round((Get-Item $fullPath).Length / 1MB, 2)
        Write-ColorOutput "    [+] $tool ($size MB)" "Green"
    } else {
        Write-ColorOutput "    [!] $tool - NOT FOUND" "Red"
        $missingTools += $tool
    }
}

if ($missingTools.Count -gt 0) {
    Write-ColorOutput ""
    Write-ColorOutput "[!] ERROR: Missing tools: $($missingTools -join ', ')" "Red"
    Write-ColorOutput "[!] Please ensure tools are downloaded to: $LocalToolsPath" "Yellow"
    exit 1
}

Write-ColorOutput ""

# Process each client
foreach ($client in $clients) {
    Write-ColorOutput "========================================" "Yellow"
    Write-ColorOutput "Uploading to: $($client.Name)" "Yellow"
    Write-ColorOutput "========================================" "Yellow"
    Write-ColorOutput ""
    
    # Create C:\Tools directory
    Write-ColorOutput "[*] Creating C:\Tools directory..." "Cyan"
    $result = SSH-Exec -Host $client.IP -Port $client.Port -User $client.User `
        -Command "powershell.exe -Command `"New-Item -ItemType Directory -Path C:\Tools -Force | Out-Null; Write-Host 'Ready'`""
    Write-ColorOutput "    $result" "Gray"
    
    # Upload each tool
    foreach ($tool in $tools) {
        Write-ColorOutput "[*] Uploading $tool to $($client.Name)..." "Cyan"
        
        $localFile = Join-Path $LocalToolsPath $tool
        $remotePath = "C:\Tools\$tool"
        
        $result = SCP-Upload -Host $client.IP -Port $client.Port -User $client.User `
            -LocalFile $localFile -RemotePath $remotePath
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "    [+] $tool uploaded successfully" "Green"
        } else {
            Write-ColorOutput "    [!] $tool upload failed: $result" "Red"
        }
    }
    
    # Verify uploads
    Write-ColorOutput ""
    Write-ColorOutput "[*] Verifying uploads on $($client.Name)..." "Cyan"
    $verifyCmd = "powershell.exe -Command `"Get-ChildItem C:\Tools\*.exe | Select-Object Name, @{N='SizeMB';E={[math]::Round(`$_.Length/1MB,2)}} | Format-Table -AutoSize`""
    $result = SSH-Exec -Host $client.IP -Port $client.Port -User $client.User -Command $verifyCmd
    
    $result | ForEach-Object { Write-ColorOutput "    $_" "Gray" }
    
    # Count uploaded tools
    $uploadedCount = ($result | Select-String -Pattern "\.exe").Count
    if ($uploadedCount -ge $tools.Count) {
        Write-ColorOutput "    [+] All tools verified on $($client.Name)" "Green"
    } else {
        Write-ColorOutput "    [!] WARNING: Only $uploadedCount/$($tools.Count) tools found" "Yellow"
    }
    
    Write-ColorOutput ""
}

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Upload Complete" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "[+] Attack tools deployed to all Platform Range clients" "Green"
Write-ColorOutput "[+] Tools location: C:\Tools\" "Green"
Write-ColorOutput ""
Write-ColorOutput "Next Steps:" "Cyan"
Write-ColorOutput "1. SSH to client01: ssh -i $SSHKey -p 42429 platform\administrator@192.168.255.254" "White"
Write-ColorOutput "2. Navigate to tools: cd C:\Tools" "White"
Write-ColorOutput "3. Test Certify: .\Certify.exe find /vulnerable" "White"
Write-ColorOutput "4. Follow ESC1 attack flow: docs/plans/3_platform_Attack_Flow.md" "White"
Write-ColorOutput ""

