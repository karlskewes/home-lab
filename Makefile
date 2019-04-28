NODE?=
KUBESPRAY_VERSION=master
## Alternatively by branch, eg: release-2.9

.PHONY: all
all: help

.PHONY:
run-ansible-site: ## Run local site.yml
	ANSIBLE_CONFIG=./ansible/ansible.cfg ansible-playbook -b -i ansible/env-dev/hosts.ini ansible/site.yml

.PHONY:
run-kubespray: ## Run ansible playbook
	cd kubespray; \
		git checkout "$(KUBESPRAY_VERSION)"; \
		cd ..; \
		ANSIBLE_CONFIG=./ansible/ansible.cfg ansible-playbook -b -i ansible/env-dev/hosts.ini kubespray/cluster.yml --extra-vars "@ansible/kubespray_overrides.yml"

.PHONY:
add-node: ## Add Kubespray node - usage: 'make add-node NODE=<your-node>'
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -b -i ansible/env-dev/hosts.ini --extra-vars "node=$(NODE)" kubespray/scale.yml

.PHONY:
remove-node: ## Remove Kubespray node - usage: 'make remove-node NODE=<your-node>'
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -b -i ansible/env-dev/hosts.ini --extra-vars "node=$(NODE)" kubespray/remove-node.yml

.PHONY:
setup-kubespray: ## Setup Kubespray release version
	cd kubespray; \
		git fetch upstream "$(KUBESPRAY_VERISON)"; \
		git checkout -b "$(KUBESPRAY_VERISON)" "upstream/$(KUBESPRAY_VERSION)"

.PHONY:
update-kubespray: ## Update kubespray repo and cp sample vars
	cd kubespray; \
		git fetch upstream "$(KUBESPRAY_VERISON)"; \
		git checkout "$(KUBESPRAY_VERISON)"; \
		git merge "upstream/$(KUBESPRAY_VERSION)"; \
		git push origin "$(KUBESPRAY_VERISON)"; \
		cd ../ansible; \
		cp -r ../kubespray/inventory/sample/group_vars/* env-dev/group_vars/


.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
