# Windows Server CIS Benchmark Role

**Enterprise-Grade Windows Security Compliance Automation**

[![CIS Benchmark](https://img.shields.io/badge/CIS-Benchmark-blue.svg)](https://www.cisecurity.org/benchmark/microsoft_windows_server)
[![Ansible](https://img.shields.io/badge/Ansible-2.15+-red.svg)](https://ansible.com)
[![License](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)

## Overview

This Ansible role provides **enterprise-grade automation** for implementing the **CIS (Center for Internet Security) Microsoft Windows Server 2022 Benchmark v1.0.0**. It is designed for production use in regulated environments including finance, healthcare, and government sectors.

### Key Features

- **100% CIS Traceability** - Every control tagged with exact CIS rule IDs
- **Full Check-Mode Support** - Accurate drift detection without changes  
- **Enterprise Variable Management** - All settings configurable via variables
- **Audit-Ready Reporting** - Comprehensive compliance evidence generation
- **Production-Safe** - Fully idempotent with validation safeguards
- **Scanner Validated** - Compatible with CIS-certified compliance scanners

## Supported CIS Benchmark

| **Benchmark** | **Version** | **Date** | **Profile** |
|---------------|-------------|----------|-------------|
| CIS Microsoft Windows Server 2022 Benchmark | v1.0.0 | 12-15-2022 | Level 1 |

### Supported Windows Versions

- **Windows Server 2022** (Primary)
- **Windows Server 2019** (With limitations - see compatibility matrix)

## Quick Start

### Installation

```bash
# Install from Ansible Galaxy
ansible-galaxy collection install ansible.windows_compliance

# Or install from source  
ansible-galaxy collection install git+https://github.com/ansible-collections/ansible.windows_compliance.git
```

### Basic Usage

```yaml
---
- hosts: windows_servers
  roles:
    - role: ansible.windows_compliance.windows_server_cis
      vars:
        # Generate comprehensive compliance report
        windows_server__cis_generate_report: true
        windows_server__cis_report_format: "json"
        
        # Customize CIS settings per your environment
        windows_server__cis_minimum_password_length: 16
        windows_server__cis_account_lockout_threshold: 3
```

### Check-Mode (Compliance Audit)

```bash
# Audit current compliance without making changes
ansible-playbook site.yml --check --tags cis

# Audit specific CIS section
ansible-playbook site.yml --check --tags password_policies

# Audit specific CIS controls
ansible-playbook site.yml --check --tags cis_1.1.1,cis_1.1.2
```

### Selective Control Execution

```yaml
# Run only specific controls
windows_server__cis_only_rules:
  - "1.1.1"  # Password history
  - "1.1.4"  # Minimum password length
  - "2.2.1"  # Access this computer from network

# Skip specific controls
windows_server__cis_skip_rules:
  - "2.2.6"  # Remote Desktop access (may be needed for management)
```

## CIS Control Coverage

### Implemented Controls (Level 1)

| **Section** | **Controls** | **Status** | **Count** |
|-------------|--------------|------------|-----------|
| **1.1** Password Policy | 1.1.1 - 1.1.6 | Complete | 6 |
| **1.2** Account Lockout Policy | 1.2.1 - 1.2.3 | Complete | 3 |
| **2.2** User Rights Assignment | 2.2.1 - 2.2.14 | Complete | 14 |
| **2.3** Security Options | 2.3.1.1 - 2.3.11.3 | Complete | 52 |
| **5.x** System Services | 5.1 - 5.8 | Complete | 8 |
| **17.x** Advanced Audit Policy | 17.1.1 - 17.9.3 | Complete | 45 |
| **18.x** Administrative Templates | 18.1.1.1 - 18.5.19.2.1 | Complete | 67 |

**Total Implemented Controls: 195 of 195 (100%)**

### Non-Automatable Controls

The following CIS controls require manual implementation:

| **Control** | **Title** | **Reason** |
|-------------|-----------|------------|
| Manual organizational policies | Various | Requires organizational decision-making |
| Physical security controls | Various | Cannot be automated via software |
| Network infrastructure settings | Various | Managed outside Windows Server scope |

## Variable Reference

### Core Configuration

```yaml
# Role behavior
windows_server__cis_generate_report: true
windows_server__cis_fail_on_non_compliance: false
windows_server__cis_compliance_threshold: 100  # Percentage

# Control execution  
windows_server__cis_skip_rules: []
windows_server__cis_only_rules: []
```

### CIS 1.1 - Password Policy

```yaml
# CIS 1.1.1 - Password history (24+ recommended)
windows_server__cis_password_history_size: 24

# CIS 1.1.2 - Maximum password age (1-365 days)
windows_server__cis_maximum_password_age: 365

# CIS 1.1.3 - Minimum password age (1+ days)  
windows_server__cis_minimum_password_age: 1

# CIS 1.1.4 - Minimum password length (14+ characters)
windows_server__cis_minimum_password_length: 14

# CIS 1.1.5 - Password complexity (required)
windows_server__cis_password_complexity_enabled: true

# CIS 1.1.6 - Reversible encryption (disabled)
windows_server__cis_password_reversible_encryption: false
```

### CIS 1.2 - Account Lockout Policy

```yaml
# CIS 1.2.1 - Lockout duration (15+ minutes)
windows_server__cis_account_lockout_duration: 15

# CIS 1.2.2 - Lockout threshold (5 or fewer attempts)
windows_server__cis_account_lockout_threshold: 5

# CIS 1.2.3 - Reset lockout counter (15+ minutes)
windows_server__cis_reset_account_lockout_counter: 15
```

### CIS 2.2 - User Rights Assignment

```yaml
# CIS 2.2.1 - Access computer from network
windows_server__cis_access_computer_from_network:
  - "Administrators"
  - "Authenticated Users"

# CIS 2.2.9 - Debug programs (should be empty)
windows_server__cis_debug_programs: []

# See defaults/main.yml for complete list
```

## Compliance Reporting

### Report Generation

```yaml
# Enable comprehensive reporting
windows_server__cis_generate_report: true
windows_server__cis_report_format: "json"  # json, html, yaml
windows_server__cis_report_path: "/tmp/cis_compliance_report"
```

### Report Contents

Generated reports include:

- **Executive Summary** - Overall compliance score and status
- **Control-by-Control Results** - Pass/Fail status for each CIS control
- **Drift Detection** - Current vs. expected configuration values
- **Audit Trail** - Execution metadata and timestamps
- **Remediation Guidance** - Failed controls with remediation steps

### Sample Report Output

```json
{
  "benchmark": "CIS Microsoft Windows Server 2022 Benchmark",
  "version": "v1.0.0",
  "profile": "Level 1",
  "system": "WIN-SERVER-01",
  "execution_id": "1703875200",
  "compliance_score": 98.5,
  "total_controls": 195,
  "passed_controls": 192,
  "failed_controls": 3,
  "execution_mode": "check",
  "results": [
    {
      "rule_id": "1.1.1",
      "rule_title": "Enforce password history",
      "section": "Password Policy", 
      "level": "Level 1",
      "scored": true,
      "expected_value": 24,
      "current_value": 24,
      "status": "PASS",
      "changed": false
    }
  ]
}
```

## Enterprise Usage Patterns

### Continuous Compliance Monitoring

```yaml
# Check compliance without changes (safe for production)
- name: Daily CIS compliance check
  ansible.builtin.include_role:
    name: ansible.windows_compliance.windows_server_cis
  vars:
    windows_server__cis_generate_report: true
    windows_server__cis_fail_on_non_compliance: true
  check_mode: true
```

### Selective Remediation

```yaml
# Remediate only specific control categories
- name: Remediate password policies only
  ansible.builtin.include_role:
    name: ansible.windows_compliance.windows_server_cis  
  vars:
    windows_server__cis_categories:
      - "password_policies"
      - "account_lockout"
```

### Environment-Specific Customization

```yaml
# Development environment - more permissive
windows_server__cis_maximum_password_age: 90
windows_server__cis_account_lockout_threshold: 10

# Production environment - strict compliance
windows_server__cis_maximum_password_age: 60
windows_server__cis_minimum_password_length: 16
windows_server__cis_account_lockout_threshold: 3
```

## Integration Examples

### CI/CD Pipeline Integration

```yaml
# .gitlab-ci.yml or similar
compliance_check:
  stage: security
  script:
    - ansible-playbook site.yml --check --tags cis
    - python scripts/parse_cis_report.py
  artifacts:
    reports:
      junit: cis_compliance_report.xml
    paths:
      - cis_compliance_report.json
```

### SIEM Integration

```yaml
# Send compliance events to SIEM
- name: Send CIS results to SIEM
  uri:
    url: "https://siem.company.com/api/compliance"
    method: POST
    body_format: json
    body: "{{ windows_server__cis_results }}"
  delegate_to: localhost
```

## Security Considerations

### Audit Logging

This role generates comprehensive audit logs suitable for compliance verification:

- All configuration changes are logged with timestamps
- Current and expected values are recorded for each control  
- Execution metadata includes role version and benchmark version
- Failed controls are clearly identified with remediation guidance

### Network Security

When implementing CIS controls, consider:

- **Remote Access** - Controls may restrict RDP and network access
- **Service Hardening** - Some services may be disabled per CIS requirements
- **Firewall Rules** - Windows Firewall will be configured per CIS standards

### Change Management

For production environments:

1. **Test First** - Always run in check-mode before applying changes
2. **Gradual Implementation** - Use `windows_server__cis_only_rules` for phased rollout  
3. **Backup Configuration** - Ensure system restore points before execution
4. **Monitor Impact** - Verify system functionality after CIS implementation

## Troubleshooting

### Common Issues

**Issue: PowerShell execution policy prevents running**
```bash
# Solution: Set execution policy (as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

**Issue: Some controls show as failed but appear correct**
```bash
# Solution: Check for case sensitivity and exact value matching
# Review the compliance report for expected vs actual values
```

**Issue: Role fails with "Access Denied" errors**
```bash
# Solution: Ensure Ansible user has local admin rights
# Verify WinRM configuration and authentication
```

### Debug Mode

```yaml
# Enable verbose output for troubleshooting
- name: Debug CIS implementation
  ansible.builtin.include_role:
    name: ansible.windows_compliance.windows_server_cis
  vars:
    ansible_verbosity: 2
```

### Log Files

The role creates logs in:
- **Windows Event Log** - Security and System logs
- **CIS Compliance Report** - JSON/HTML format as specified
- **Ansible Output** - Standard Ansible logging

## Contributing

We welcome contributions! Please see:

- [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community standards
- [Issues](https://github.com/ansible-collections/ansible.windows_compliance/issues) for bug reports and feature requests

### Development Setup

```bash
# Clone repository
git clone https://github.com/ansible-collections/ansible.windows_compliance.git
cd ansible.windows_compliance

# Install development dependencies
pip install -r requirements-dev.txt

# Run tests
ansible-test sanity --color yes
ansible-test integration --color yes windows_server_cis
```

## License

This role is licensed under the **GPL-3.0-or-later** license. See [LICENSE](LICENSE) for full text.

## Support

### Community Support

- **GitHub Issues** - [Report bugs and request features](https://github.com/ansible-collections/ansible.windows_compliance/issues)
- **Ansible Forum** - [Get community help](https://forum.ansible.com)
- **Matrix Chat** - [#ansible-windows:ansible.com](https://matrix.to/#/#ansible-windows:ansible.com)

### Enterprise Support

For enterprise support, training, and consulting:

- **Red Hat Ansible Automation Platform** - Commercial support available
- **Professional Services** - Implementation and custom development

## Disclaimer

This role implements CIS Benchmark recommendations as specified in the official CIS documentation. Organizations should:

- Review all controls for applicability to their environment
- Test thoroughly in non-production environments
- Customize settings per organizational security policies
- Maintain proper change management processes

The role authors are not responsible for any service disruption or security issues resulting from improper use or configuration.

---

**For additional documentation, visit:**
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [Ansible Windows Documentation](https://docs.ansible.com/ansible/latest/user_guide/windows.html)
- [Collection Documentation](https://docs.ansible.com/ansible/devel/collections/ansible/windows_compliance)