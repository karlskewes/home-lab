# Kubernetes with Gitlab

Create and maintain a multi-arch Kubernetes cluster utilizing Gitlab CI/CD tools where possible.
(Initially ARM64 but will add AMD64 node(s) later.)

## Prerequisites

6x Rock64 SBC's running Ubuntu and Kubernetes. 3x Masters with SSD disk, 3x Workers with eMMC disk.
1+ amd64 if using multi-arch

- [Burn OS Image](https://github.com/ayufan-rock64/linux-build/releases) - bionic-minimal-rock64-0.7.11-1075-arm64.img.xz
- [Install Ansible](https://docs.ansible.com)
- Install recent kernel: `sudo apt update && sudo apt install linux-image-4.19.0-1073-ayufan-ga6e013135a6e`

**Networking:**

| Item | Range |
| :--- | :--- |
| Network | 192.168.1.0/24 |
| Gateway | 192.168.1.1 |
| Ingress | 192.168.1.4x | 
| K8s Masters | 192.168.1.5x | 
| K8s Workers | 192.168.1.6x |

## Diagnostics

- [Rock64 Serial](https://forum.pine64.org/showthread.php?tid=5029) - From right, skip 2 pins, ground (6), TX (8), RX (10)
- `sudo  minicom  -s  -D  /dev/ttyUSB0  -b  1500000  --color=on`

## Getting Started

0. Git clone this repo and submodules ([kubespray](https://github.com/kubernetes-sigs/kubespray)) - `git clone --recurse-submodules ...`
1. Prepare your hardware
2. Ansible configure operating system
   - Edit Ansible inventory, variables as required.
   - Run Ansible playbook `ansible-playbook -i env-dev/hosts.yml site.yml`
3. Ansible configure Kubernetes cluster
   - Edit Ansible inventory, variables as required.
   - Run Ansible playbook `site.yml`
4. Gitlab Setup
