# Baker Street Scenarios - Current Operational Status

**Last Updated**: 2026-01-08  
**Status**: 🟢 **OPERATIONAL**

---

## Current State

### Primary Active Scenario: Active Directory Attack Simulation

**Status**: ✅ **FULLY OPERATIONAL** - This is the scenario the Platform Range was 100% built for

**Documentation Location**: `E:\richard-downloads\Ranges\`

**Components**:
- ✅ Infrastructure Plan (`1_Infrastructure_Plan.md`) - Complete
- ✅ Configuration Plan (`2_Configuration_Plan.md`) - Complete
- ✅ Attack Flow (`3_Attack_Flow.md`) - Complete
- ✅ Overview Guide (`0_README.md`) - Complete

**Attack Techniques Covered**: 12 critical techniques
- ✅ Basic AD Enumeration
- ✅ SharpHound Collection
- ✅ SPN Enumeration
- ✅ AS-REP Roasting
- ✅ Kerberoasting
- ✅ Password Spraying
- ✅ Pass the Hash
- ✅ Pass the Ticket
- ✅ Shadow Credentials
- ✅ ESC1 (AD CS)
- ✅ DCSync
- ✅ Golden Ticket

---

### Range Platform Variants

#### Range XDR Attack Scenario

**Status**: ✅ Operational  
**Domain**: `moriartyxdr.ad.bakerstreetlabs.io`  
**Configuration Script**: `scripts/Configure-AD-Complete-XDR.ps1`  
**Documents**: `docs/plans/0_range_xdr_*.md`, `1_range_xdr_*.md`, `2_range_xdr_*.md`, `3_range_xdr_*.md`

#### Range XSIAM Attack Scenario

**Status**: ✅ Operational  
**Domain**: `moriartysiam.ad.bakerstreetlabs.io`  
**Configuration Script**: `scripts/Configure-AD-Complete-XSIAM.ps1`  
**Documents**: `docs/plans/0_range_xsiam_*.md`, `1_range_xsiam_*.md`, `2_range_xsiam_*.md`, `3_range_xsiam_*.md`

#### Platform Range Attack Scenario

**Status**: ✅ Operational  
**Domain**: `platform.bakerstreetlabs.io` (standalone forest)  
**SSH Access**: Port 42425  
**Automation**: AWX/Ansible ready  
**Documents**: `docs/plans/0_platform_*.md`, `1_platform_*.md`, `2_platform_*.md`, `3_platform_*.md`

---

### Live Fire Range

**Status**: ✅ Operational  
**Location**: `docs/baker_street_live_fire_range.md`  
**Network**: `172.30.3.80/28` (macvlan on cybernet)  
**Services**: 9 intentionally vulnerable web applications (Apache, Log4J, Jenkins, WordPress, Joomla, Struts, Drupal, Magento, phpMyAdmin)

---

## Recent Changes

**2026-01-08**: Documentation migration complete - all scenario docs consolidated per strict documentation rules.

**2025-12-02**: Active Directory Attack Simulation documents finalized - primary active scenario documentation complete.

**2025-11-17**: Range XDR and XSIAM scenarios deployed and operational.

**2025-10-15**: Platform Range automation scripts completed - SSH-accessible infrastructure operational.

---

## Known Issues

None currently. All scenarios operational.

---

## Next Steps

- ⏳ Additional MITRE ATT&CK scenario development
- ⏳ Automated scenario deployment via Ansible
- ⏳ Scenario replay and reset automation
- ⏳ Integration with C2 frameworks for advanced scenarios

