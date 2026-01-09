# Baker Street Scenarios

**Cyber Range Attack Scenarios and Simulation Guides**  
**Status**: 🟢 **OPERATIONAL**  
**Last Updated**: January 8, 2026

---

## Overview

Baker Street Scenarios contains comprehensive attack simulation guides and scenario documentation for the Baker Street Labs cyber range. The **Active Directory Attack Simulation** is the primary active scenario that the Platform Range was 100% built for, providing professional attack demonstrations for security product sales and customer education.

---

## 🎯 Primary Active Scenario: Active Directory Attack Simulation

**This is the scenario the Platform Range was built for.**

### Complete Guide Documents

**Documentation Location**: `E:\richard-downloads\Ranges\`

The Active Directory Attack Simulation consists of four comprehensive documents:

1. **0_README.md** (`E:\richard-downloads\Ranges\0_README.md`) - Complete Guide Overview
   - Quick start guide
   - Attack technique coverage (12 critical techniques)
   - Resource requirements
   - Demo narrative arc
   - Success metrics

2. **1_Infrastructure_Plan.md** (`E:\richard-downloads\Ranges\1_Infrastructure_Plan.md`) - Infrastructure Setup
   - Network topology and VM specifications
   - Domain Controller deployment
   - Certificate Authority configuration
   - Client workstation setup
   - Snapshot strategy
   - **Time Required**: 4-6 hours (one-time setup)

3. **2_Configuration_Plan.md** (`E:\richard-downloads\Ranges\2_Configuration_Plan.md`) - Configuration Guide
   - User account creation (admins, service accounts, standard users)
   - Vulnerable configurations (AS-REP Roasting, Kerberoasting targets)
   - Certificate template setup (ESC1 vulnerability)
   - Shadow Credentials permissions
   - Attack tool installation and verification
   - **Time Required**: 2-3 hours

4. **3_Attack_Flow.md** (`E:\richard-downloads\Ranges\3_Attack_Flow.md`) - Attack Execution
   - Step-by-step attack execution
   - Commands and expected outputs
   - Detection points and value messaging
   - Demo narrative and talking points
   - Troubleshooting guide
   - **Time Required**: 20-30 minutes per demo execution

### Attack Technique Coverage

This demonstration covers **12 critical attack techniques**:

| # | Attack Technique | MITRE ATT&CK | Tool Used | Duration |
|---|------------------|--------------|-----------|----------|
| 1 | Basic AD Enumeration | T1087.002 | Native/PowerView | 2 min |
| 2 | SharpHound Collection | T1087.002 | SharpHound | 3 min |
| 3 | SPN Enumeration | T1558.003 | Rubeus | 1 min |
| 4 | AS-REP Roasting | T1558.004 | Rubeus | 2 min |
| 5 | Kerberoasting | T1558.003 | Rubeus | 2 min |
| 6 | Password Spraying | T1110.003 | CrackMapExec | 3 min |
| 7 | Pass the Hash | T1550.002 | Mimikatz | 2 min |
| 8 | Pass the Ticket | T1550.003 | Rubeus | 1 min |
| 9 | Shadow Credentials | T1556.007 | Whisker | 2 min |
| 10 | ESC1 (AD CS) | T1649 | Certify | 2 min |
| 11 | DCSync | T1003.006 | Mimikatz | 2 min |
| 12 | Golden Ticket | T1558.001 | Mimikatz/Rubeus | 3 min |

**Total Demo Time**: 20-30 minutes  
**Detection Coverage**: 12 critical detection points that traditional tools miss

---

## Range Platform Variants

### Range XDR Attack Scenario

**Domain**: `moriartyxdr.ad.bakerstreetlabs.io`  
**Purpose**: XDR product demonstration scenarios

**Documents**:
- `docs/plans/0_range_xdr_README.md` - Overview and quick start
- `docs/plans/1_range_xdr_Infrastructure_Plan.md` - XDR infrastructure setup
- `docs/plans/2_range_xdr_Configuration_Plan.md` - XDR configuration guide
- `docs/plans/3_range_xdr_Attack_Flow.md` - XDR attack execution

**Configuration Script**: `scripts/Configure-AD-Complete-XDR.ps1`

### Range XSIAM Attack Scenario

**Domain**: `moriartysiam.ad.bakerstreetlabs.io`  
**Purpose**: XSIAM product demonstration scenarios

**Documents**:
- `docs/plans/0_range_xsiam_README.md` - Overview and quick start
- `docs/plans/1_range_xsiam_Infrastructure_Plan.md` - XSIAM infrastructure setup
- `docs/plans/2_range_xsiam_Configuration_Plan.md` - XSIAM configuration guide
- `docs/plans/3_range_xsiam_Attack_Flow.md` - XSIAM attack execution

**Configuration Script**: `scripts/Configure-AD-Complete-XSIAM.ps1`

### Platform Range Attack Scenario

**Domain**: `platform.bakerstreetlabs.io` (standalone forest)  
**Purpose**: Platform automation and SSH-accessible infrastructure

**Documents**:
- `docs/plans/0_platform_README.md` - Platform overview
- `docs/plans/1_platform_Infrastructure_Plan.md` - Platform infrastructure
- `docs/plans/2_platform_Configuration_Plan.md` - Platform configuration (SSH-automated)
- `docs/plans/3_platform_Attack_Flow.md` - Platform attack execution

**Unique Features**:
- SSH-accessible infrastructure (port 42425)
- AWX/Ansible automation ready
- Simplified standalone domain architecture

---

## Live Fire Range

**Purpose**: Training-only sandbox with intentionally vulnerable web applications

**Location**: `docs/baker_street_live_fire_range.md`

**Services**:
- Apache (Log4Shell vulnerability)
- Jenkins (CI/CD pipeline replay)
- WordPress (Missing Crown Jewels case)
- Joomla (Copper Beeches dossier)
- Struts (Baskerville Beacon intel)
- Drupal (Field report)
- Magento (E-commerce orders)
- phpMyAdmin

**Network**: `172.30.3.80/28` (macvlan on cybernet network)

---

## Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Complete technical architecture for all scenarios
- **[DESIGN.md](DESIGN.md)** - Scenario workflow diagrams and attack flows
- **[STATUS.md](STATUS.md)** - Current operational status of all scenarios
- **[CHANGES.md](CHANGES.md)** - Development history and scenario updates
- **[ROADMAP.md](ROADMAP.md)** - Future scenario development plans

---

## Key Features

- ✅ 12 critical AD attack techniques demonstrated
- ✅ Complete infrastructure setup guides
- ✅ Automated configuration scripts
- ✅ Step-by-step attack execution guides
- ✅ Detection points and value messaging
- ✅ Demo narratives and talking points
- ✅ Range XDR and XSIAM variants
- ✅ Live Fire Range with vulnerable applications

---

## Quick Start

### First-Time Setup (Active Directory Attack Simulation)

1. **Infrastructure Setup** (4-6 hours)
   - Follow `E:\richard-downloads\Ranges\1_Infrastructure_Plan.md`
   - Deploy Domain Controller, CA, clients, attacker workstation
   - Take snapshots at each milestone

2. **Configuration** (2-3 hours)
   - Follow `E:\richard-downloads\Ranges\2_Configuration_Plan.md`
   - Create users, service accounts, vulnerable configurations
   - Install attack tools
   - Take final "Pre-Attack" snapshot

3. **Practice Demo** (1-2 hours)
   - Run through `E:\richard-downloads\Ranges\3_Attack_Flow.md`
   - Practice narrative and timing
   - Familiarize with detection alerts

### Regular Demo Execution

1. Revert all VMs to "Pre-Attack" snapshot
2. Verify security product connectivity
3. Open security console
4. Follow `E:\richard-downloads\Ranges\3_Attack_Flow.md` step-by-step
5. Reset after each demo

---

## Related Components

- **[baker-street-traffic-generators](../baker-street-traffic-generators/README.md)**: Realistic network traffic simulation for scenarios
- **[baker-street-c2](../baker-street-c2/README.md)**: Mythic C2 framework for advanced attack scenarios
- **[baker-street-integrations](../baker-street-integrations/README.md)**: PKI automation and PANOS integration for certificate attacks

---

**Version**: 1.0  
**Environment**: Baker Street Labs Cyber Range  
**Primary Use Case**: Security product demonstrations and customer education
