#cloud-config
# vim: syntax=yaml

users:
- name: "${user_name}"
  gecos: "${user_name}"
  groups: users, sudo
  lock_passwd: true  # Prevent login with user/pass
  shell: /bin/bash
  ssh_authorized_keys:
  - "${user_ssh_authorized_keys}"
  sudo: ["ALL=(ALL) NOPASSWD:ALL"]

# Uncomment for root user/pass combo
# ssh_pwauth: yes
# chpasswd:
#   list: |
#    root:mypassword
#   expire: False

growpart:
  mode: auto
  devices: ["/"]
  ignore_growroot_disabled: false

timezone: Pacific/Auckland

hostname: "${hostname}"
fqdn: "${fqdn}"
manage_etc_hosts: localhost

# Uncomment if require python2 for Ansible or qemu-guest-agent
# packages:
# - python
# - qemu-guest-agent

# Uncomment to upgrade automatically
# package_update: true
# package_upgrade: true

final_message: "Boot finished at $TIMESTAMP, after $UPTIME seconds"
