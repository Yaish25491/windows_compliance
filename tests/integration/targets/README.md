# Integration Tests

This directory contains integration tests for the windows_compliance collection.

## Test Naming Convention

All test targets must have names starting with `win_` prefix to ensure proper execution in the Windows testing environment.

## Test Structure

Each test target should follow this structure:

- `meta/main.yml` - Dependencies on shared setup roles
- `tasks/main.yml` - Test logic with block/rescue/always structure  
- `vars/main.yml` - Test-specific variables and configuration

## Running Tests

1. Set environment variables:
   ```bash
   export COMPLIANCE_HOSTNAME="your-windows-host"
   export COMPLIANCE_USERNAME="your-username"
   export COMPLIANCE_PASSWORD="your-password"
   ```

2. Generate inventory:
   ```bash
   cd tests/integration
   ./generate_inventory.sh
   ```

3. Run specific test:
   ```bash
   ansible-test integration win_security_baseline --docker
   ```

## Test Targets

- `prepare_tests` - Shared setup and configuration for all tests
- `win_security_baseline` - Tests for STIG role functionality
- `win_cis_baseline` - Tests for CIS role functionality