NODE? :=
KUBESPRAY_VERSION := release-2.10
# KUBESPRAY_VERSION := master
## Alternatively by branch, eg: release-2.9
ANSIBLE_HOSTS := ansible/env-dev/hosts.ini
ANSIBLE_CONFIG := ./ansible/ansible.cfg
KVM_HOSTS := $(shell ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible kvm -i $(ANSIBLE_HOSTS) --list-hosts | grep -v 'hosts' | xargs)
KVM_HOST := kvmhost1

.PHONY: all
all: help

.PHONY: reboot-cluster
reboot-cluster: ## Reboot all nodes in cluster
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible -m reboot -b -i $(ANSIBLE_HOSTS) k8s-cluster

.PHONY: shutdown-cluster
shutdown-cluster: ## Shutdown all nodes in cluster
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible -m shell -a '/sbin/shutdown -h now' -b -i $(ANSIBLE_HOSTS) k8s-cluster

.PHONY: start-kvm-hosts
start-kvm-hosts: ## Start up KVM VM Hosts
	for host in $(KVM_HOSTS); do \
		ssh $(KVM_HOST) LIBVIRT_DEFAULT_URI=qemu:///system virsh start $${host}; \
		done

.PHONY: deploy-ansible-site
deploy-ansible-site: ## Run your local ansible site.yml playbook
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) ansible/site.yml

.PHONY: deploy-ansible-edgeos
deploy-ansible-edgeos: ## Run your local ansible edgeos.yml playbook
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -i $(ANSIBLE_HOSTS) ansible/edgeos.yml

.PHONY: deploy-kubespray
deploy-kubespray: ## Install/upgrade Kubespray
	cd kubespray; \
		git checkout "$(KUBESPRAY_VERSION)"; \
		cd ..; \
		ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) kubespray/cluster.yml --extra-vars "@ansible/kubespray_overrides.yml"

.PHONY: reset-kubespray
reset-kubespray: ## Reset Kubespray cluster - will remove everything!
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) --extra-vars "node=$(NODE)" kubespray/reset.yml

.PHONY: add-node-kubespray
add-node-kubespray: ## Add Kubespray node - usage: 'make add-node NODE=<your-node>'
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) --extra-vars "node=$(NODE)" kubespray/scale.yml

.PHONY: remove-node-kubespray
remove-node-kubespray: ## Remove Kubespray node - usage: 'make remove-node NODE=<your-node>'
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) --extra-vars "node=$(NODE)" kubespray/remove-node.yml

.PHONY: setup-kubespray
setup-kubespray: ## Setup Kubespray release version - one time operation
	cd kubespray; \
		git fetch upstream "$(KUBESPRAY_VERSION)"; \
		git checkout -b "$(KUBESPRAY_VERSION)" "upstream/$(KUBESPRAY_VERSION)"

.PHONY: update-kubespray
update-kubespray: ## Update Kubespray repo and copy sample vars to local ansible
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
