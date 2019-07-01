# Kubernetes with Gitlab

Create and maintain a multi-arch Kubernetes cluster utilizing Gitlab CI/CD tools where possible.

## Prerequisites

- 6x Rock64 SBC's running Ubuntu and Kubernetes. 
  - 3x Masters with SSD disk
  - 3x Workers with eMMC disk.
- 1x AMD64 Host running KVM. 
  - (will create) 3x Workers provisioned with Terraform.

- [Burn OS Image](https://github.com/ayufan-rock64/linux-build/releases) - bionic-minimal-rock64-0.7.11-1075-arm64.img.xz
- [Install Ansible](https://docs.ansible.com)
- [Install Terraform](https://terraform.io) 
- [Install terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt/)

**Networking:**

| Item | Range |
| :--- | :--- |
| Network | 192.168.1.0/24 |
| Gateway | 192.168.1.1 |
| Ingress | 192.168.2.0/28 | 
| K8s Masters | 192.168.1.5x (TODO: change to .48/29)| 
| ARM64 K8s Workers | 192.168.1.6x (TODO: change to .64/28)|
| AMD64 K8s Workers | 192.168.1.7x (TODO: change to .80/28)|

## Diagnostics

- [Rock64 Serial](https://forum.pine64.org/showthread.php?tid=5029) - From right, skip 2 pins, ground (6), TX (8), RX (10)
- `sudo  minicom  -s  -D  /dev/ttyUSB0  -b  1500000  --color=on`

## Getting Started

0. Git clone this repo and submodules ([kubespray](https://github.com/kubernetes-sigs/kubespray)) - `git clone --recurse-submodules ...`
1. Prepare your hardware
2. Provison Terraform nodes
3. Configure Ansible
   - Edit Ansible inventory, variables as required
   - `make deploy-ansible-site`
4. Ansible configure Kubernetes cluster
   - Edit Ansible inventory, variables as required
   - `make deploy-kubespray`
5. Retrieve Kubernetes cluster-admin credentials
   - `make retrive-kubespray-kubeconfig`
6. Deploy Kubernetes applications
   - Edit as required
   - `kubectl apply -f kubernetes/`
7. BGP Peer EdgeRouter and Metallb
   - `make deploy-ansible-edgeos`
8. TODO: Gitlab Setup
