# Kubernetes with Gitlab helper

# Use commonly available shell
SHELL := bash
# Fail if piped commands fail - critical for CI/etc
.SHELLFLAGS := -eu -o pipefail -c
# Use one shell for a target, rather than shell per line
.ONESHELL:


ANSIBLE_HOSTS := ansible/env-dev/hosts.ini
ANSIBLE_CONFIG := ./ansible/ansible.cfg
ANSIBLE_EXTRA_ARGS? :=
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
		ssh $(KVM_HOST) LIBVIRT_DEFAULT_URI=qemu:///system virsh start $${host}
	done

.PHONY: deploy-ansible-site
deploy-ansible-site: ## Run your local ansible site.yml playbook
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -b -i $(ANSIBLE_HOSTS) ansible/site.yml

.PHONY: deploy-ansible-edgeos
deploy-ansible-edgeos: ## Run your local ansible edgeos.yml playbook
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook -i $(ANSIBLE_HOSTS) ansible/edgeos.yml

.PHONY: deploy-terraform
deploy-terraform: ## Terraform apply kvm
	@echo "Not implemented yet:
	1. cd matchbox && terraform apply
	2. cd typhoon && terraform apply
	3. cd k8s-nodes && terraform apply
	"

.PHONY: update-k8s-nodes
update-k8s-nodes: ## Update Kubernetes nodes FLATCAR_VERSION=2605.7.0
	ssh matchbox-00 '/etc/matchbox/matchbox_getflatcar.sh stable $(FLATCAR_VERSION) /var/lib/matchbox/assets'
	@echo "Kubernetes node update process:
	1. matchbox - update flatcar linux version (passed to get flatcar script) for cache
	2. matchbox - terraform destroy & terraform apply recreate & wait for ready
	^^ consider just running get_flatcar.sh instead to pull new images
	3. typhoon - terraform apply to update/recreate ignition/configs in matchbox
	3. loop
	4. kubernetes - drain node
	5. cd terraform/k8s-node && terraform destroy node and its volume (without destroying all volumes)
	6. cd terraform/typhoon && terraform destory null resource copy secrets ? - (required for provisioner to copy secrets)
	6. cd terraform/typhoon && terraform apply  - copy secrets - hangs until vm created and ready for provisioner
	7. cd terraform/k8s-node && terraform apply - apply to create replacement node
	7. kubernetes - wait for new node to join cluster
	8. continue loop
	"

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
