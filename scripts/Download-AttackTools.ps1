#Requires -Version 5.1
<#
.SYNOPSIS
    Downloads Active Directory attack tools for cyber range training and demonstrations.

.DESCRIPTION
    This script downloads all required attack tools including:
    - SharpHound (reconnaissance)
    - BloodHound (visualization)
    - Rubeus (Kerberos attacks)
    - Mimikatz (credential extraction)
    - Whisker (Shadow Credentials)
    - Certify (AD CS exploitation)
    - CrackMapExec (lateral movement)
    - PowerView (reconnaissance)
    - Impacket (Python tools)

.PARAMETER ToolsDirectory
    Base directory where tools will be downloaded. Default: C:\Tools

.PARAMETER SkipGitClone
    Skip cloning Git repositories (if compilation not needed). Default: $false

.EXAMPLE
    .\Download-AttackTools.ps1
    
.EXAMPLE
    .\Download-AttackTools.ps1 -ToolsDirectory "D:\AttackTools"

.NOTES
    Author: Baker Street Labs
    Purpose: Cyber Range / Academic Training
    All tools are open-source and used for authorized security testing only.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ToolsDirectory = "C:\Tools",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipGitClone
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Color output function
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Download function with retry logic
function Invoke-ToolDownload {
    param(
        [string]$Uri,
        [string]$OutputPath,
        [string]$ToolName,
        [int]$MaxRetries = 3
    )
    
    $retryCount = 0
    $success = $false
    
    while ($retryCount -lt $MaxRetries -and -not $success) {
        try {
            Write-ColorOutput "  [*] Downloading $ToolName..." "Yellow"
            
            # Create parent directory if it doesn't exist
            $parentDir = Split-Path -Path $OutputPath -Parent
            if (-not (Test-Path -Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            
            # Download with progress
            Invoke-WebRequest -Uri $Uri -OutFile $OutputPath -UseBasicParsing -ErrorAction Stop
            
            if (Test-Path -Path $OutputPath) {
                $fileSize = (Get-Item -Path $OutputPath).Length
                Write-ColorOutput "  [+] Successfully downloaded $ToolName ($([math]::Round($fileSize/1MB, 2)) MB)" "Green"
                $success = $true
            } else {
                throw "File not found after download"
            }
        } catch {
            $retryCount++
            if ($retryCount -lt $MaxRetries) {
                Write-ColorOutput "  [!] Download failed, retrying ($retryCount/$MaxRetries)..." "Yellow"
                Start-Sleep -Seconds 2
            } else {
                Write-ColorOutput "  [!] Failed to download $ToolName after $MaxRetries attempts: $($_.Exception.Message)" "Red"
            }
        }
    }
    
    return $success
}

# Extract ZIP file
function Expand-ToolArchive {
    param(
        [string]$ZipPath,
        [string]$DestinationPath,
        [string]$ToolName
    )
    
    try {
        Write-ColorOutput "  [*] Extracting $ToolName..." "Yellow"
        
        if (-not (Test-Path -Path $DestinationPath)) {
            New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        }
        
        Expand-Archive -Path $ZipPath -DestinationPath $DestinationPath -Force -ErrorAction Stop
        Write-ColorOutput "  [+] Successfully extracted $ToolName" "Green"
        return $true
    } catch {
        Write-ColorOutput "  [!] Failed to extract $ToolName : $($_.Exception.Message)" "Red"
        return $false
    }
}

# Check if Git is available
function Test-GitAvailable {
    try {
        $null = git --version 2>&1
        return $true
    } catch {
        return $false
    }
}

# Clone Git repository
function Invoke-ToolClone {
    param(
        [string]$RepositoryUrl,
        [string]$DestinationPath,
        [string]$ToolName
    )
    
    # Check if Git is available
    if (-not (Test-GitAvailable)) {
        Write-ColorOutput "  [!] Git is not installed or not in PATH" "Red"
        Write-ColorOutput "  [~] Install Git: https://git-scm.com/download/win" "Yellow"
        Write-ColorOutput "  [~] Or clone manually: git clone $RepositoryUrl" "Yellow"
        return $false
    }
    
    try {
        Write-ColorOutput "  [*] Cloning $ToolName repository..." "Yellow"
        
        $parentDir = Split-Path -Path $DestinationPath -Parent
        if (-not (Test-Path -Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        
        # Remove existing directory if it exists
        if (Test-Path -Path $DestinationPath) {
            Remove-Item -Path $DestinationPath -Recurse -Force
        }
        
        $cloneOutput = git clone $RepositoryUrl $DestinationPath 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Git clone failed: $cloneOutput"
        }
        
        if (Test-Path -Path $DestinationPath) {
            Write-ColorOutput "  [+] Successfully cloned $ToolName repository" "Green"
            return $true
        } else {
            throw "Repository directory not found after clone"
        }
    } catch {
        Write-ColorOutput "  [!] Failed to clone $ToolName : $($_.Exception.Message)" "Red"
        Write-ColorOutput "  [~] Manual clone: git clone $RepositoryUrl" "Yellow"
        return $false
    }
}

# Get latest GitHub release download URL
function Get-GitHubReleaseUrl {
    param(
        [string]$RepositoryOwner,
        [string]$RepositoryName,
        [string]$AssetPattern = "*.exe"
    )
    
    try {
        # Try GitHub API to get latest release
        $apiUrl = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/releases/latest"
        $release = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing -ErrorAction Stop
        
        # Find matching asset
        $asset = $release.assets | Where-Object { $_.name -like $AssetPattern } | Select-Object -First 1
        if ($asset) {
            return $asset.browser_download_url
        }
    } catch {
        # If API fails, return null to try fallback URL
        return $null
    }
    
    return $null
}

# Main execution
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "AD Attack Tools Download Script" "Cyan"
Write-ColorOutput "Purpose: Cyber Range / Academic Training" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-Host ""

# Create base tools directory structure
Write-ColorOutput "[*] Creating directory structure..." "Yellow"
$directories = @(
    "$ToolsDirectory\Reconnaissance",
    "$ToolsDirectory\CredentialAccess",
    "$ToolsDirectory\PrivilegeEscalation",
    "$ToolsDirectory\LateralMovement"
)

foreach ($dir in $directories) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-ColorOutput "  [+] Created: $dir" "Gray"
    }
}
Write-Host ""

# Track download results
$downloadResults = @{
    Successful = 0
    Failed = 0
    Skipped = 0
}

# ========================================
# RECONNAISSANCE TOOLS
# ========================================
Write-ColorOutput "[*] Downloading Reconnaissance Tools..." "Cyan"
Write-Host ""

# SharpHound.exe
$sharphoundExe = "$ToolsDirectory\Reconnaissance\SharpHound.exe"
if (-not (Test-Path -Path $sharphoundExe)) {
    # Try to get latest release URL via API
    $sharphoundUrl = Get-GitHubReleaseUrl -RepositoryOwner "BloodHoundAD" -RepositoryName "SharpHound" -AssetPattern "SharpHound*.exe"
    
    # Fallback to common release URL patterns
    if (-not $sharphoundUrl) {
        $sharphoundUrl = "https://github.com/BloodHoundAD/SharpHound/releases/download/v2.4.2/SharpHound.exe"
    }
    
    if (Invoke-ToolDownload -Uri $sharphoundUrl `
                            -OutputPath $sharphoundExe `
                            -ToolName "SharpHound.exe") {
        $downloadResults.Successful++
    } else {
        # Try alternative: download from main branch artifacts
        Write-ColorOutput "  [~] Trying alternative download method..." "Yellow"
        $altUrl = "https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Collectors/SharpHound.exe"
        if (Invoke-ToolDownload -Uri $altUrl -OutputPath $sharphoundExe -ToolName "SharpHound.exe (alternative)") {
            $downloadResults.Successful++
        } else {
            Write-ColorOutput "  [!] Manual download: https://github.com/BloodHoundAD/SharpHound/releases" "Yellow"
            $downloadResults.Failed++
        }
    }
} else {
    Write-ColorOutput "  [~] SharpHound.exe already exists, skipping" "Yellow"
    $downloadResults.Skipped++
}

# SharpHound.ps1
$sharphoundPs1 = "$ToolsDirectory\Reconnaissance\SharpHound.ps1"
if (-not (Test-Path -Path $sharphoundPs1)) {
    if (Invoke-ToolDownload -Uri "https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Collectors/SharpHound.ps1" `
                            -OutputPath $sharphoundPs1 `
                            -ToolName "SharpHound.ps1") {
        $downloadResults.Successful++
    } else {
        $downloadResults.Failed++
    }
} else {
    Write-ColorOutput "  [~] SharpHound.ps1 already exists, skipping" "Yellow"
    $downloadResults.Skipped++
}

# BloodHound
Write-ColorOutput "  [*] BloodHound application..." "Yellow"
Write-ColorOutput "  [~] Download from: https://github.com/SpecterOps/BloodHound/releases/latest" "Gray"
Write-ColorOutput "  [~] Or install via: choco install bloodhound -y" "Gray"
Write-ColorOutput "  [~] Neo4j required: choco install neo4j-community -y" "Gray"
$downloadResults.Skipped++

# PowerView
$powerview = "$ToolsDirectory\Reconnaissance\PowerView.ps1"
if (-not (Test-Path -Path $powerview)) {
    if (Invoke-ToolDownload -Uri "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1" `
                            -OutputPath $powerview `
                            -ToolName "PowerView.ps1") {
        $downloadResults.Successful++
    } else {
        $downloadResults.Failed++
    }
} else {
    Write-ColorOutput "  [~] PowerView.ps1 already exists, skipping" "Yellow"
    $downloadResults.Skipped++
}

Write-Host ""

# ========================================
# CREDENTIAL ACCESS TOOLS
# ========================================
Write-ColorOutput "[*] Downloading Credential Access Tools..." "Cyan"
Write-Host ""

# Mimikatz
$mimikatzZip = "$ToolsDirectory\CredentialAccess\mimikatz.zip"
$mimikatzDir = "$ToolsDirectory\CredentialAccess\mimikatz"
if (-not (Test-Path -Path "$mimikatzDir\x64\mimikatz.exe")) {
    if (Invoke-ToolDownload -Uri "https://github.com/gentilkiwi/mimikatz/releases/latest/download/mimikatz_trunk.zip" `
                            -OutputPath $mimikatzZip `
                            -ToolName "Mimikatz") {
        if (Expand-ToolArchive -ZipPath $mimikatzZip -DestinationPath $mimikatzDir -ToolName "Mimikatz") {
            # Copy main executable to tools root
            if (Test-Path -Path "$mimikatzDir\x64\mimikatz.exe") {
                Copy-Item -Path "$mimikatzDir\x64\mimikatz.exe" -Destination "$ToolsDirectory\CredentialAccess\mimikatz.exe" -Force
                Write-ColorOutput "  [+] Copied mimikatz.exe to CredentialAccess directory" "Green"
            }
            $downloadResults.Successful++
            # Cleanup zip
            Remove-Item -Path $mimikatzZip -Force -ErrorAction SilentlyContinue
        } else {
            $downloadResults.Failed++
        }
    } else {
        $downloadResults.Failed++
    }
} else {
    Write-ColorOutput "  [~] Mimikatz already exists, skipping" "Yellow"
    $downloadResults.Skipped++
}

# Rubeus
Write-ColorOutput "  [*] Rubeus..." "Yellow"
if (-not $SkipGitClone) {
    $rubeusDir = "$ToolsDirectory\CredentialAccess\Rubeus"
    if (-not (Test-Path -Path "$rubeusDir\Rubeus.sln")) {
        if (Invoke-ToolClone -RepositoryUrl "https://github.com/GhostPack/Rubeus.git" `
                             -DestinationPath $rubeusDir `
                             -ToolName "Rubeus") {
            $downloadResults.Successful++
        } else {
            $downloadResults.Failed++
        }
    } else {
        Write-ColorOutput "  [~] Rubeus repository already exists, skipping" "Yellow"
        $downloadResults.Skipped++
    }
} else {
    Write-ColorOutput "  [~] Skipping Rubeus (Git clone disabled)" "Gray"
    Write-ColorOutput "  [~] Releases: https://github.com/GhostPack/Rubeus/releases" "Gray"
    $downloadResults.Skipped++
}

Write-Host ""

# ========================================
# PRIVILEGE ESCALATION TOOLS
# ========================================
Write-ColorOutput "[*] Downloading Privilege Escalation Tools..." "Cyan"
Write-Host ""

# Certify
$certifyExe = "$ToolsDirectory\PrivilegeEscalation\Certify.exe"
if (-not (Test-Path -Path $certifyExe)) {
    # Try to get latest release URL via API
    $certifyUrl = Get-GitHubReleaseUrl -RepositoryOwner "GhostPack" -RepositoryName "Certify" -AssetPattern "Certify*.exe"
    
    # Try various release tag patterns
    if (-not $certifyUrl) {
        $certifyVersions = @("v1.0.0", "1.0.0", "v1.1.0", "1.1.0")
        foreach ($version in $certifyVersions) {
            $testUrl = "https://github.com/GhostPack/Certify/releases/download/$version/Certify.exe"
            try {
                $null = Invoke-WebRequest -Uri $testUrl -Method Head -UseBasicParsing -ErrorAction Stop
                $certifyUrl = $testUrl
                break
            } catch {
                continue
            }
        }
    }
    
    $certifyDownloaded = $false
    if ($certifyUrl) {
        if (Invoke-ToolDownload -Uri $certifyUrl -OutputPath $certifyExe -ToolName "Certify.exe") {
            $certifyDownloaded = $true
            $downloadResults.Successful++
        }
    }
    
    # If download failed, offer Git clone option
    if (-not $certifyDownloaded -and -not $SkipGitClone) {
        $certifyDir = "$ToolsDirectory\PrivilegeEscalation\Certify"
        if (-not (Test-Path -Path "$certifyDir\Certify.sln")) {
            Write-ColorOutput "  [*] Attempting to clone Certify repository for compilation..." "Yellow"
            if (Invoke-ToolClone -RepositoryUrl "https://github.com/GhostPack/Certify.git" `
                                 -DestinationPath $certifyDir `
                                 -ToolName "Certify") {
                $downloadResults.Successful++
                Write-ColorOutput "  [~] Compile with: MSBuild Certify.sln /p:Configuration=Release" "Gray"
            } else {
                Write-ColorOutput "  [!] Manual download: https://github.com/GhostPack/Certify/releases" "Yellow"
                $downloadResults.Failed++
            }
        } else {
            Write-ColorOutput "  [~] Certify repository already exists, skipping" "Yellow"
            $downloadResults.Skipped++
        }
    } elseif (-not $certifyDownloaded) {
        Write-ColorOutput "  [!] Pre-compiled Certify.exe not found in releases" "Yellow"
        Write-ColorOutput "  [~] Check releases: https://github.com/GhostPack/Certify/releases" "Gray"
        Write-ColorOutput "  [~] Or clone repository for compilation: git clone https://github.com/GhostPack/Certify.git" "Gray"
        $downloadResults.Failed++
    }
} else {
    Write-ColorOutput "  [~] Certify.exe already exists, skipping" "Yellow"
    $downloadResults.Skipped++
}

# Whisker
Write-ColorOutput "  [*] Whisker..." "Yellow"
if (-not $SkipGitClone) {
    $whiskerDir = "$ToolsDirectory\PrivilegeEscalation\Whisker"
    if (-not (Test-Path -Path "$whiskerDir\Whisker.sln")) {
        if (Invoke-ToolClone -RepositoryUrl "https://github.com/eladshamir/Whisker.git" `
                             -DestinationPath $whiskerDir `
                             -ToolName "Whisker") {
            $downloadResults.Successful++
            Write-ColorOutput "  [~] Compile with: MSBuild Whisker.sln /p:Configuration=Release" "Gray"
        } else {
            $downloadResults.Failed++
        }
    } else {
        Write-ColorOutput "  [~] Whisker repository already exists, skipping" "Yellow"
        $downloadResults.Skipped++
    }
} else {
    Write-ColorOutput "  [~] Skipping Whisker (Git clone disabled)" "Gray"
    $downloadResults.Skipped++
}

Write-Host ""

# ========================================
# LATERAL MOVEMENT TOOLS
# ========================================
Write-ColorOutput "[*] Downloading Lateral Movement Tools..." "Cyan"
Write-Host ""

# CrackMapExec
Write-ColorOutput "  [*] CrackMapExec..." "Yellow"
Write-ColorOutput "  [~] Install via pip: pip install crackmapexec --break-system-packages" "Gray"
Write-ColorOutput "  [~] Or download from: https://github.com/byt3bl33d3r/CrackMapExec/releases" "Gray"
$downloadResults.Skipped++

# Impacket
Write-ColorOutput "  [*] Impacket..." "Yellow"
if (-not $SkipGitClone) {
    $impacketDir = "$ToolsDirectory\LateralMovement\impacket"
    if (-not (Test-Path -Path "$impacketDir\setup.py")) {
        if (Invoke-ToolClone -RepositoryUrl "https://github.com/fortra/impacket.git" `
                             -DestinationPath $impacketDir `
                             -ToolName "Impacket") {
            Write-ColorOutput "  [~] Install with: pip install . --break-system-packages" "Gray"
            $downloadResults.Successful++
        } else {
            $downloadResults.Failed++
        }
    } else {
        Write-ColorOutput "  [~] Impacket repository already exists, skipping" "Yellow"
        $downloadResults.Skipped++
    }
} else {
    Write-ColorOutput "  [~] Skipping Impacket (Git clone disabled)" "Gray"
    $downloadResults.Skipped++
}

Write-Host ""

# ========================================
# SUMMARY
# ========================================
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "DOWNLOAD SUMMARY" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Successful: $($downloadResults.Successful)" "Green"
Write-ColorOutput "Failed: $($downloadResults.Failed)" $(if ($downloadResults.Failed -eq 0) { "Green" } else { "Red" })
Write-ColorOutput "Skipped: $($downloadResults.Skipped)" "Yellow"
Write-Host ""

Write-ColorOutput "[*] Tools directory: $ToolsDirectory" "Cyan"
Write-Host ""

# Verify key tools
Write-ColorOutput "[*] Verifying key tools..." "Yellow"
$keyTools = @(
    @{ Name = "SharpHound.exe"; Path = "$ToolsDirectory\Reconnaissance\SharpHound.exe" }
    @{ Name = "Mimikatz"; Path = "$ToolsDirectory\CredentialAccess\mimikatz.exe" }
    @{ Name = "PowerView.ps1"; Path = "$ToolsDirectory\Reconnaissance\PowerView.ps1" }
)

$verified = 0
foreach ($tool in $keyTools) {
    if (Test-Path -Path $tool.Path) {
        Write-ColorOutput "  [+] $($tool.Name) - Verified" "Green"
        $verified++
    } else {
        Write-ColorOutput "  [!] $($tool.Name) - Missing" "Yellow"
    }
}

Write-Host ""
Write-ColorOutput "[*] Script execution complete!" "Cyan"
Write-ColorOutput "[*] Note: Some tools require compilation (Rubeus, Certify, Whisker)" "Yellow"
Write-ColorOutput "[*] Note: BloodHound requires Neo4j database installation" "Yellow"
Write-ColorOutput "[*] Note: CrackMapExec and Impacket require Python pip installation" "Yellow"
Write-Host ""
Write-ColorOutput "[*] All tools are for authorized security testing only." "Cyan"

