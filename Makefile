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
	cd terraform/env-dev/libvirt-k8s
	terraform apply

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
