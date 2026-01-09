# Changelog

All updates, changes, and summaries are recorded here (append-only).

---

## 2026-01-08 - Documentation Migration

- Consolidated all scenario documentation from monorepo
- Created 6 root documentation files per strict rules
- Migrated Active Directory Attack Simulation content (primary active scenario)
- Migrated Range XDR, XSIAM, and Platform Range variants
- Migrated Live Fire Range content

---

## Active Directory Attack Simulation Development

### Primary Active Scenario - Platform Range Foundation

**Status**: ✅ Production Ready  
**Date**: December 2, 2025

**Purpose**: This is the scenario the Platform Range was 100% built for - professional attack demonstrations for security product sales and customer education.

**Documents Created**:
1. `0_README.md` - Complete guide overview with quick start, attack techniques, resource requirements
2. `1_Infrastructure_Plan.md` - Infrastructure setup (4-6 hours, one-time)
3. `2_Configuration_Plan.md` - Configuration guide (2-3 hours)
4. `3_Attack_Flow.md` - Attack execution (20-30 minutes per demo)

**Attack Techniques**:
- 12 critical AD attack techniques demonstrated
- Complete MITRE ATT&CK mapping
- Step-by-step execution guides
- Detection points and value messaging
- Demo narratives and talking points

**Key Features**:
- Complete infrastructure setup guides
- Automated configuration scripts
- Pre-attack snapshot strategy
- Troubleshooting guides
- Post-demo reset procedures

---

## Range XDR Attack Scenario Development

**Status**: ✅ Production Ready  
**Date**: November 17, 2025

**Deployment**:
- Domain: `moriartyxdr.ad.bakerstreetlabs.io`
- Configuration script: `scripts/Configure-AD-Complete-XDR.ps1`
- Complete documentation suite (0-3 documents)

**Purpose**: XDR product demonstration scenarios with specific detection focus.

---

## Range XSIAM Attack Scenario Development

**Status**: ✅ Production Ready  
**Date**: November 17, 2025

**Deployment**:
- Domain: `moriartysiam.ad.bakerstreetlabs.io`
- Configuration script: `scripts/Configure-AD-Complete-XSIAM.ps1`
- Complete documentation suite (0-3 documents)

**Purpose**: XSIAM product demonstration scenarios with security analytics focus.

---

## Platform Range Attack Scenario Development

**Status**: ✅ Production Ready  
**Date**: October 15, 2025

**Deployment**:
- Domain: `platform.bakerstreetlabs.io` (standalone forest)
- SSH-accessible infrastructure (port 42425)
- AWX/Ansible automation ready
- Modular PowerShell scripts for configuration

**Unique Features**:
- SSH access to all Windows VMs (OpenSSH configured)
- Automated configuration via Master-Configure-AD-Platform.ps1
- Simplified standalone domain architecture
- AWX/Ansible integration ready

---

## Live Fire Range Development

**Status**: ✅ Operational

**Deployment**:
- Network: `172.30.3.80/28` (macvlan on cybernet)
- Services: 9 intentionally vulnerable web applications
- Persistent storage: `/opt/bakerstreet-livefire`
- Themed evidence seeded throughout applications

**Services**:
- Apache (221B Incident Board)
- Log4J (Live hunt checklist)
- Jenkins (CI evidence locker)
- WordPress (Baker Street Gazette)
- Joomla (Copper Beeches dossier)
- Struts (Baskerville Beacon intel)
- Drupal (Field report)
- Magento (Decoy e-commerce orders)
- phpMyAdmin (Academic disclaimer)

---

## Scenario Scripts and Automation

**PowerShell Configuration Scripts**:
- `scripts/Configure-AD-Complete-XDR.ps1` - Complete XDR range configuration
- `scripts/Configure-AD-Complete-XSIAM.ps1` - Complete XSIAM range configuration
- `scripts/platform/Master-Configure-AD-Platform.ps1` - Platform range orchestrator
- `scripts/platform/Platform-AD-Common.ps1` - Common platform functions
- `scripts/platform/Section*.ps1` - Modular configuration sections

**Attack Tool Scripts**:
- `scripts/platform/Download-AttackTools.ps1` - Automated tool download
- `scripts/platform/Upload-AttackTools-AllClients.ps1` - Tool distribution
- `scripts/platform/Test-RangeSSHAccess.ps1` - SSH connectivity testing

---

## Certificate Attack (ESC1) Integration

**Status**: ✅ Fully Integrated

**Certificate Template Creation**:
- `docs/scripts/Create-ESC1Template-Enterprise.ps1` - Enterprise CA template (XDR)
- `docs/scripts/Create-ESC1Template-XSIAM.ps1` - Enterprise CA template (XSIAM)
- `scripts/Create-ESC1Template-Platform.ps1` - Platform template creation

**Testing Scripts**:
- `docs/scripts/Test-ESC1Enrollment.ps1` - Certificate enrollment testing
- `docs/scripts/Test-ESC1Enrollment-XSIAM.ps1` - XSIAM enrollment testing

**Integration**: ESC1 attack (Attack #10) fully documented and operational in all range variants.

---

*"The game is afoot, and every scenario tells a story of intrigue and investigation." - Baker Street Scenarios*

