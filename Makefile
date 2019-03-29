NODE?=

.PHONY: all
all: help

.PHONY:
run-ansible-site: ## Run local site.yml
	ANSIBLE_CONFIG=./ansible/ansible.cfg ansible-playbook -b -i ansible/env-dev/hosts.ini ansible/site.yml

.PHONY:
run-kubespray: ## Run ansible playbook
	ANSIBLE_CONFIG=./ansible/ansible.cfg ansible-playbook -b -i ansible/env-dev/hosts.ini kubespray/cluster.yml --extra-vars "@ansible/kubespray_overrides.yml"

.PHONY:
add-node: ## Add Kubespray node - usage: 'make add-node NODE=<your-node>'
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -b -i ansible/env-dev/hosts.ini --extra-vars "node=$(NODE)" kubespray/scale.yml

.PHONY:
remove-node: ## Remove Kubespray node - usage: 'make remove-node NODE=<your-node>'
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -b -i ansible/env-dev/hosts.ini --extra-vars "node=$(NODE)" kubespray/remove-node.yml

.PHONY:
update-kubespray: ## Update kubespray repo and cp sample vars
	cd kubespray; \
		git pull; \
		cd ../ansible; \
		cp -r ../kubespray/inventory/sample/group_vars/* env-dev/group_vars/


.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
