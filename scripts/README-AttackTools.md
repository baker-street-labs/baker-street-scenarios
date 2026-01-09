# Platform Range - Attack Tools Deployment

## Overview

Three scripts for deploying attack tools (Certify.exe, Rubeus.exe, Mimikatz.exe) to Platform Range clients:

## Scripts

### 1. Download-AttackTools-Client.ps1
**Purpose**: Runs ON the client workstation to download tools from GitHub  
**Location**: Upload to `C:\Scripts\platform\` on each client  
**Execution**: SSH remotely or run locally on client

**Pros**:
- Self-contained, clients download directly
- No need to pre-download tools

**Cons**:
- May be blocked by Windows Defender/XDR
- Requires internet access from clients
- GitHub may block downloads

```powershell
# Upload and execute via SSH
scp -i C:\Users\richard\.ssh\id_rsa -P 42429 Download-AttackTools-Client.ps1 platform\administrator@192.168.255.254:C:\Scripts\platform\
ssh -i C:\Users\richard\.ssh\id_rsa -p 42429 platform\administrator@192.168.255.254 "powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\platform\Download-AttackTools-Client.ps1"
```

### 2. Upload-AttackTools-AllClients.ps1
**Purpose**: Automated orchestration - uploads download script to ALL clients and executes  
**Location**: Run from your local machine (E:\projects\baker-street-labs\scripts\platform\)  
**Execution**: Local PowerShell

**Pros**:
- One command deploys to all clients
- Automated verification
- Detailed logging

**Cons**:
- Still subject to XDR blocking downloads on clients
- Requires download script to work

```powershell
# Run locally
cd E:\projects\baker-street-labs\scripts\platform
.\Upload-AttackTools-AllClients.ps1
```

### 3. Manual-Upload-Tools.ps1 ⭐ RECOMMENDED
**Purpose**: Upload PRE-DOWNLOADED tools from your machine to all clients  
**Location**: Run from your local machine  
**Execution**: Local PowerShell

**Pros**:
- ✅ Bypasses XDR/antivirus on clients (tools already downloaded locally)
- ✅ Reliable - no GitHub download issues
- ✅ Deploys to all clients in one command
- ✅ Automated verification

**Cons**:
- Requires tools pre-downloaded to E:\projects\tools\

```powershell
# Step 1: Ensure you have tools locally in E:\projects\tools\
# - Certify.exe
# - Rubeus.exe
# - mimikatz.exe

# Step 2: Run upload script
cd E:\projects\baker-street-labs\scripts\platform
.\Manual-Upload-Tools.ps1
```

## Recommended Workflow

Since XDR is blocking downloads on your current client, use this approach:

### Step 1: Download Tools to Local Machine
```powershell
# Create tools directory
mkdir E:\projects\tools -Force

# Download from a non-monitored machine or use existing tools
# Copy Certify.exe, Rubeus.exe, mimikatz.exe to E:\projects\tools\
```

### Step 2: Upload to Platform Clients
```powershell
cd E:\projects\baker-street-labs\scripts\platform
.\Manual-Upload-Tools.ps1
```

This script will:
1. Verify tools exist locally
2. Create C:\Tools\ on each client
3. Upload all three tools via SCP
4. Verify uploads completed successfully

### Step 3: Verify Installation
```powershell
# SSH to client01
ssh -i C:\Users\richard\.ssh\id_rsa -p 42429 platform\administrator@192.168.255.254

# Check tools
cd C:\Tools
dir

# Test Certify
.\Certify.exe find /vulnerable

# Test Rubeus
.\Rubeus.exe version
```

## Troubleshooting

### XDR/Antivirus Blocking Downloads
If downloads are blocked on clients:
1. Use `Manual-Upload-Tools.ps1` instead (recommended)
2. Temporarily disable Windows Defender:
   ```powershell
   ssh -i C:\Users\richard\.ssh\id_rsa -p 42429 platform\administrator@192.168.255.254 'powershell.exe -Command "Set-MpPreference -DisableRealtimeMonitoring $true"'
   ```

### GitHub Rate Limiting
If GitHub blocks downloads:
- Use `Manual-Upload-Tools.ps1` with pre-downloaded tools
- Wait 1 hour and retry
- Use alternative download sources (included in script)

### SCP Upload Failures
If SCP fails:
1. Verify SSH connectivity: `ssh -i C:\Users\richard\.ssh\id_rsa -p 42429 platform\administrator@192.168.255.254 "echo Connected"`
2. Check remote path exists: `ssh ... "powershell.exe -Command 'Test-Path C:\Tools'"`
3. Verify local file paths are correct

## Client Port Mapping

| Client   | IP              | SSH Port | User                      |
|----------|-----------------|----------|---------------------------|
| client01 | 192.168.255.254 | 42429    | platform\administrator    |
| client02 | 192.168.255.254 | 42430    | platform\administrator    |
| client03 | 192.168.255.254 | 42431    | platform\administrator    |

## Next Steps

After tools are installed:
1. Follow **docs/plans/3_platform_Attack_Flow.md** for ESC1 attack execution
2. Start with reconnaissance: `.\Certify.exe find /vulnerable`
3. Execute ESC1 attack to obtain DA privileges
4. Test persistence mechanisms

## Security Note

These are offensive security tools intended ONLY for the Baker Street Labs cyber range environment. Do not deploy to production systems.

