NODE?=
KUBESPRAY_VERSION=release-2.10
# KUBESPRAY_VERSION=master
## Alternatively by branch, eg: release-2.9
ANSIBLE_HOSTS=ansible/env-dev/hosts.ini
ANSIBLE_CONFIG=./ansible/ansible.cfg

.PHONY: all
all: help

.PHONY:
cluster-reboot: ## Reboot all nodes in cluster
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible -m reboot -b -i $(ANSIBLE_HOSTS) k8s-cluster

.PHONY:
cluster-shutdown: ## Shutdown all nodes in cluster
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible -m shell -a '/sbin/shutdown -h now' -b -i $(ANSIBLE_HOSTS) k8s-cluster

.PHONY:
ansible-site: ## Run your local ansible site.yml playbook
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) ansible/site.yml

.PHONY:
kubespray-cluster: ## Install/upgrade Kubespray
	cd kubespray; \
		git checkout "$(KUBESPRAY_VERSION)"; \
		cd ..; \
		ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) kubespray/cluster.yml --extra-vars "@ansible/kubespray_overrides.yml"

.PHONY:
kubespray-reset: ## Reset Kubespray cluster - will remove everything!
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) --extra-vars "node=$(NODE)" kubespray/reset.yml

.PHONY:
kubespray-add-node: ## Add Kubespray node - usage: 'make add-node NODE=<your-node>'
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) --extra-vars "node=$(NODE)" kubespray/scale.yml

.PHONY:
kubespray-remove-node: ## Remove Kubespray node - usage: 'make remove-node NODE=<your-node>'
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) --extra-vars "node=$(NODE)" kubespray/remove-node.yml

.PHONY:
kubespray-setup: ## Setup Kubespray release version - one time operation
	cd kubespray; \
		git fetch upstream "$(KUBESPRAY_VERSION)"; \
		git checkout -b "$(KUBESPRAY_VERSION)" "upstream/$(KUBESPRAY_VERSION)"

.PHONY:
kubespray-update: ## Update Kubespray repo and copy sample vars to local ansible
	cd kubespray; \
		git fetch upstream "$(KUBESPRAY_VERSION)"; \
		git checkout "$(KUBESPRAY_VERSION)"; \
		git merge "upstream/$(KUBESPRAY_VERSION)"; \
		git push origin "$(KUBESPRAY_VERSION)"; \
		cd ../ansible; \
		cp -r ../kubespray/inventory/sample/group_vars/* env-dev/group_vars/


.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
