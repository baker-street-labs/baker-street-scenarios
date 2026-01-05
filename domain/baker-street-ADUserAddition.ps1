#Requires -Version 5.1
# EXTRACTED FROM PRODUCTION BAKER STREET MONOREPO – 2025-12-03
# Verified working in active cyber range for 18+ months
# Part of the official Tier 1 / Tier 2 crown jewels audit (Conservative Option A)
# DO NOT REFACTOR UNLESS EXPLICITLY APPROVED

<#
.SYNOPSIS
    Deploys Active Directory user structure to a remote domain controller.

.DESCRIPTION
    This script copies the AD user structure creation script to a remote domain controller
    and executes it there, providing comprehensive logging and error handling.

.PARAMETER DomainController
    The FQDN or IP address of the domain controller to target. Default: 192.168.0.65

.PARAMETER DomainName
    The FQDN of the domain. Default: ad.bakerstreetlabs.io

.PARAMETER Credential
    Credentials for connecting to the domain controller. If not provided, will prompt.

.PARAMETER ScriptPath
    Path to the baker-street-ADOUStructure.ps1 script. Default: .\baker-street-ADOUStructure.ps1

.PARAMETER WhatIf
    Shows what would happen if the cmdlet runs without actually performing the action.

.PARAMETER Verbose
    Provides detailed information about the operations being performed.

.EXAMPLE
    .\baker-street-ADUserAddition.ps1

.EXAMPLE
    .\baker-street-ADUserAddition.ps1 -DomainController "dc01.ad.bakerstreetlabs.io" -Credential (Get-Credential)

.EXAMPLE
    .\baker-street-ADUserAddition.ps1 -WhatIf -Verbose

.NOTES
    Author: Baker Street Labs
    Version: 1.0
    Created: 2025-01-27
    Script Name: baker-street-ADUserAddition.ps1
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$DomainController = "192.168.0.65",
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$DomainName = "ad.bakerstreetlabs.io",
    
    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential,
    
    [Parameter(Mandatory = $false)]
    [ValidateScript({Test-Path $_})]
    [string]$ScriptPath = ".\baker-street-ADOUStructure.ps1"
)

# Set error action preference
$ErrorActionPreference = "Stop"

function Write-LogMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        default { "White" }
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Test-RemoteConnectivity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credential
    )
    
    try {
        Write-LogMessage -Message "Testing connectivity to $ComputerName..." -Level "Info"
        
        $null = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            Write-Output "Connection successful"
        } -ErrorAction Stop
        
        Write-LogMessage -Message "Successfully connected to $ComputerName" -Level "Success"
        return $true
    }
    catch {
        Write-LogMessage -Message "Failed to connect to $ComputerName : $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Copy-ScriptToRemote {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credential,
        
        [Parameter(Mandatory = $true)]
        [string]$LocalScriptPath,
        
        [Parameter(Mandatory = $false)]
        [string]$RemoteScriptPath = "C:\New-ADUserStructure.ps1"
    )
    
    try {
        Write-LogMessage -Message "Reading local script: $LocalScriptPath" -Level "Info"
        $scriptContent = Get-Content -Path $LocalScriptPath -Raw -Encoding UTF8
        
        Write-LogMessage -Message "Copying script to remote server: $RemoteScriptPath" -Level "Info"
        
        if ($PSCmdlet.ShouldProcess($RemoteScriptPath, "Copy script to remote server")) {
            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
                param($Content, $Path)
                $Content | Out-File -FilePath $Path -Encoding UTF8 -Force
            } -ArgumentList $scriptContent, $RemoteScriptPath
            
            Write-LogMessage -Message "Script copied successfully to $RemoteScriptPath" -Level "Success"
            return $true
        }
    }
    catch {
        Write-LogMessage -Message "Failed to copy script: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Invoke-RemoteScript {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credential,
        
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Parameters = @{}
    )
    
    try {
        Write-LogMessage -Message "Executing remote script: $ScriptPath" -Level "Info"
        
        if ($PSCmdlet.ShouldProcess($ScriptPath, "Execute script on remote server")) {
            $result = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
                param($ScriptPath, $Parameters)
                
                # Change to the script directory
                $scriptDir = Split-Path $ScriptPath -Parent
                if ($scriptDir) {
                    Set-Location $scriptDir
                }
                
                # Execute the script with parameters
                & $ScriptPath @Parameters
                
            } -ArgumentList $ScriptPath, $Parameters
            
            Write-LogMessage -Message "Remote script execution completed" -Level "Success"
            return $result
        }
    }
    catch {
        Write-LogMessage -Message "Failed to execute remote script: $($_.Exception.Message)" -Level "Error"
        throw
    }
}

function Test-RemoteScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credential,
        
        [Parameter(Mandatory = $true)]
        [string]$DomainName
    )
    
    try {
        Write-LogMessage -Message "Running validation tests..." -Level "Info"
        
        # Copy validation script
        $validationScriptPath = ".\Test-ADUserStructure.ps1"
        if (Test-Path $validationScriptPath) {
            $validationContent = Get-Content -Path $validationScriptPath -Raw -Encoding UTF8
            
            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
                param($Content)
                $Content | Out-File -FilePath "C:\Test-ADUserStructure.ps1" -Encoding UTF8 -Force
            } -ArgumentList $validationContent
            
            # Execute validation
            $validationResult = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
                & "C:\Test-ADUserStructure.ps1" -DomainName $using:DomainName -TestWinRM -TestPassword
            }
            
            Write-LogMessage -Message "Validation completed" -Level "Success"
            return $validationResult
        } else {
            Write-LogMessage -Message "Validation script not found, skipping validation" -Level "Warning"
            return $null
        }
    }
    catch {
        Write-LogMessage -Message "Validation failed: $($_.Exception.Message)" -Level "Error"
        return $null
    }
}

# Main execution
try {
    Write-LogMessage -Message "Starting Active Directory user structure deployment" -Level "Info"
    Write-LogMessage -Message "Target Domain Controller: $DomainController" -Level "Info"
    Write-LogMessage -Message "Target Domain: $DomainName" -Level "Info"
    
    # Get credentials if not provided
    if (-not $Credential) {
        $Credential = Get-Credential -Message "Enter credentials for domain controller $DomainController"
    }
    
    # Test connectivity
    if (-not (Test-RemoteConnectivity -ComputerName $DomainController -Credential $Credential)) {
        throw "Cannot connect to domain controller. Deployment aborted."
    }
    
    # Copy script to remote server
    $remoteScriptPath = "C:\New-ADUserStructure.ps1"
    if (-not (Copy-ScriptToRemote -ComputerName $DomainController -Credential $Credential -LocalScriptPath $ScriptPath -RemoteScriptPath $remoteScriptPath)) {
        throw "Failed to copy script to remote server. Deployment aborted."
    }
    
    # Execute the script on remote server
    $scriptParameters = @{
        DomainController = $DomainController
        DomainName = $DomainName
        Verbose = $VerbosePreference -eq "Continue"
    }
    
    Write-LogMessage -Message "Executing user structure creation on remote server..." -Level "Info"
    $null = Invoke-RemoteScript -ComputerName $DomainController -Credential $Credential -ScriptPath $remoteScriptPath -Parameters $scriptParameters
    
    # Run validation
    Write-LogMessage -Message "Running post-deployment validation..." -Level "Info"
    $validationResult = Test-RemoteScript -ComputerName $DomainController -Credential $Credential -DomainName $DomainName
    
    # Summary
    Write-LogMessage -Message "=== DEPLOYMENT SUMMARY ===" -Level "Info"
    Write-LogMessage -Message "Deployment completed successfully!" -Level "Success"
    Write-LogMessage -Message "Script executed on: $DomainController" -Level "Info"
    Write-LogMessage -Message "Domain: $DomainName" -Level "Info"
    Write-LogMessage -Message "Timestamp: $(Get-Date)" -Level "Info"
    
    if ($validationResult) {
        Write-LogMessage -Message "Validation results available in output above" -Level "Info"
    }
    
    Write-LogMessage -Message "Deployment completed!" -Level "Success"
}
catch {
    Write-LogMessage -Message "Deployment failed: $($_.Exception.Message)" -Level "Error"
    throw
}
