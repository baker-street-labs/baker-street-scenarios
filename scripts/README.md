# Platform Range AD Configuration Scripts

Modular PowerShell scripts for configuring Active Directory on the Platform Range (platform.bakerstreetlabs.io).

## Structure

- **Platform-AD-Common.ps1** - Common configuration and initialization (domain variables, module imports)
- **Section01-CreateOUs.ps1** through **Section12-Verification.ps1** - Individual configuration sections
- **Master-Configure-AD-Platform.ps1** - Master orchestrator that executes all sections in sequence

## Usage

### Execute All Sections
```powershell
cd C:\Scripts\platform
.\Master-Configure-AD-Platform.ps1
```

### Execute Specific Sections
```powershell
# Execute sections 1-5 only
.\Master-Configure-AD-Platform.ps1 -StartFromSection 1 -StopAtSection 5

# Execute from section 8 onwards
.\Master-Configure-AD-Platform.ps1 -StartFromSection 8

# Execute single section
.\Master-Configure-AD-Platform.ps1 -StartFromSection 3 -StopAtSection 3
```

### Execute Individual Sections
```powershell
# Each section can be run independently
.\Section01-CreateOUs.ps1
.\Section02-CreateAdminAccounts.ps1
# ... etc
```

### Skip Verification
```powershell
.\Master-Configure-AD-Platform.ps1 -SkipVerification
```

## Section Breakdown

1. **Section01-CreateOUs.ps1** - Creates Demo_* Organizational Units
2. **Section02-CreateAdminAccounts.ps1** - Creates da_admin, it_admin1, it_admin2
3. **Section03-CreateServiceAccounts.ps1** - Creates svc_sql, svc_web, svc_iis, svc_sharepoint with SPNs
4. **Section04-CreateStandardUsers.ps1** - Creates 10 standard user accounts
5. **Section05-CreateASREPRoastable.ps1** - Creates nopreauth1, nopreauth2, legacyapp (AS-REP roasting)
6. **Section06-CreateInsiderAccount.ps1** - Creates insider account (initial compromise)
7. **Section07-CreateTargetUser.ps1** - Creates targetuser for Shadow Credentials
8. **Section08-ConfigureShadowCredentials.ps1** - Configures ACL permissions for Shadow Credentials
9. **Section09-MoveUsersToOUs.ps1** - Moves users/computers to appropriate OUs
10. **Section10-EnableLogging.ps1** - Enables AD auditing policies
11. **Section11-ConfigureLockoutPolicy.ps1** - Disables account lockout for demo
12. **Section12-Verification.ps1** - Verifies configuration and prints summary

## Benefits of Modular Approach

- **Isolate Errors**: If one section fails, others can still run
- **Incremental Execution**: Run sections individually to test/debug
- **Resume Capability**: Continue from where you left off
- **Easier Debugging**: Smaller scripts are easier to troubleshoot
- **Selective Execution**: Only run needed sections

## Deployment

1. Upload all scripts to `C:\Scripts\platform\` on AD01
2. Ensure all scripts are in the same directory
3. Run master script or individual sections as needed

## Domain Configuration

- **Domain**: platform.bakerstreetlabs.io
- **NetBIOS**: PLATFORM
- **DN**: DC=platform,DC=bakerstreetlabs,DC=io
- **Password**: Cortex1! (all accounts)

