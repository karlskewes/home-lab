# Home lab

Multi-arch Kubernetes cluster for experimenting with various tools.

## Prerequisites

**Hardware (or any combination):**
- 3x+ Rock64 SBC's running Ubuntu and Kubernetes
   - 6x workers with eMMC/SD disk
   - [OS image on media](https://github.com/ayufan-rock64/linux-build/releases) - latest bionic-minimal-rock64 or Armbian
- 1x AMD64 Host running KVM
   - 3x controllers with 3xUSB SATA SSD provisioned with Terraform, more
       reliable than Rock64.
   - 3x workers for AMD64 only apps

**Software:**
- [Terraform](https://terraform.io)
- [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt/)

**Networking:**

| Item | Range |
| :--- | :--- |
| Network | 192.168.2.0/24 |
| Gateway | 192.168.2.1 |
| Ingress | 192.168.3.0/28 |
| AMD64 K8s Masters | 192.168.2.32
| ARM64 K8s Workers | 192.168.2.64+

## Diagnostics

- [Rock64 Serial](https://forum.pine64.org/showthread.php?tid=5029) - From right, skip 2 pins, ground (6), TX (8), RX (10)
- `sudo minicom -s -D /dev/ttyUSB0 -b 1500000 --color=on`

## Getting Started

1. Prepare hardware
2. Provison Terraform nodes
   - TODO: `make deploy-terraform`
3. Configure Ansible
   - Edit Ansible inventory, variables as required
   - `make deploy-ansible-site`
4. Deploy Kubernetes applications
   - TODO: `make deploy-kubernetes`
   - `kubectl apply -f kubernetes/`
5. BGP Peer EdgeRouter and Metallb
   - `make deploy-ansible-edgeos`
