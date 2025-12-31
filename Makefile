ANSIBLE_COLLECTIONS_PATH ?= ~/.ansible/collections

# setup commands
.PHONY: upgrade-collections
upgrade-collections:
	ansible-galaxy collection install --upgrade -p $(ANSIBLE_COLLECTIONS_PATH) .

.PHONY: install-integration-reqs
install-integration-reqs:
	pip install -r tests/integration/requirements.txt; \
	ansible-galaxy collection install --upgrade -r tests/integration/requirements.yml -p $(ANSIBLE_COLLECTIONS_PATH)

tests/integration/inventory.winrm:
	chmod +x ./tests/integration/generate_inventory.sh; \
	./tests/integration/generate_inventory.sh

# test commands
.PHONY: sanity
sanity: upgrade-collections
	cd $(ANSIBLE_COLLECTIONS_PATH)/ansible_collections/ansible/windows_compliance; \
	ansible-test sanity -v --color --coverage --junit --docker default

.PHONY: lint
lint: upgrade-collections
	ansible-lint

.PHONY: integration
integration: tests/integration/inventory.winrm install-integration-reqs upgrade-collections
	cp tests/integration/inventory.winrm $(ANSIBLE_COLLECTIONS_PATH)/ansible_collections/ansible/windows_compliance/tests/integration/inventory.winrm; \
	cd $(ANSIBLE_COLLECTIONS_PATH)/ansible_collections/ansible/windows_compliance; \
	ansible --version; \
	ansible-test --version; \
	ANSIBLE_COLLECTIONS_PATH=$(ANSIBLE_COLLECTIONS_PATH)/ansible_collections ansible-galaxy collection list; \
	ANSIBLE_ROLES_PATH=$(ANSIBLE_COLLECTIONS_PATH)/ansible_collections/ansible/windows_compliance/tests/integration/targets \
		ANSIBLE_COLLECTIONS_PATH=$(ANSIBLE_COLLECTIONS_PATH)/ansible_collections \
		ansible-test windows-integration $(CLI_ARGS);

# compliance-specific commands
.PHONY: test-stig
test-stig: upgrade-collections
	cd $(ANSIBLE_COLLECTIONS_PATH)/ansible_collections/ansible/windows_compliance; \
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook playbooks/hardening.yml --check --diff -i tests/integration/inventory.winrm

.PHONY: test-cis
test-cis: upgrade-collections
	cd $(ANSIBLE_COLLECTIONS_PATH)/ansible_collections/ansible/windows_compliance; \
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook playbooks/drift_detection.yml --check --diff -i tests/integration/inventory.winrm

.PHONY: test-audit-report
test-audit-report: upgrade-collections
	cd $(ANSIBLE_COLLECTIONS_PATH)/ansible_collections/ansible/windows_compliance; \
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook playbooks/audit_report.yml --check --diff -i tests/integration/inventory.winrm

.PHONY: validate-roles
validate-roles: upgrade-collections
	ansible-playbook -i localhost, --connection=local --check \
		-e "ansible_python_interpreter=$(shell which python3)" \
		-m include_role -a name=ansible.windows_compliance.windows_server_stig \
		/dev/null; \
	ansible-playbook -i localhost, --connection=local --check \
		-e "ansible_python_interpreter=$(shell which python3)" \
		-m include_role -a name=ansible.windows_compliance.windows_server_cis \
		/dev/null

.PHONY: test-all
test-all: sanity lint validate-roles

.PHONY: clean
clean:
	rm -rf tests/integration/inventory.winrm
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	rm -rf .coverage coverage.xml