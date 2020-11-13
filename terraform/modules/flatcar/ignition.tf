data "ignition_config" "ignition" {
  count = var.custom_ignition ? 0 : var.guest_count

  users = [
    data.ignition_user.core[0].rendered,
  ]

  files = [
    element(data.ignition_file.hostname.*.rendered, count.index)
  ]

  networkd = [
    data.ignition_networkd_unit.network-dhcp[0].rendered,
  ]

  systemd = [
    data.ignition_systemd_unit.etcd-member[count.index].rendered,
  ]

}

data "ignition_file" "hostname" {
  count = var.custom_ignition ? 0 : var.guest_count

  filesystem = "root"
  path       = "/etc/hostname"
  mode       = 420

  content {
    content = "${var.guest_hostname}-${format("%02d", count.index)}"
  }
}

data "ignition_user" "core" {
  count = var.custom_ignition ? 0 : 1
  name  = "core"

  ssh_authorized_keys = [var.guest_user_ssh_authorized_key]
}

data "ignition_networkd_unit" "network-dhcp" {
  count   = var.custom_ignition ? 0 : 1
  name    = "00-wired.network"
  content = file("${path.module}/units/00-wired.network")
}

data "ignition_systemd_unit" "etcd-member" {
  count   = var.custom_ignition ? 0 : 1
  name    = "etcd-member.service"
  enabled = true
  dropin {
    content = data.template_file.etcd-member[count.index].rendered
    name    = "20-etcd-member.conf"
  }
}

resource "random_string" "token" {
  count   = var.custom_ignition ? 0 : 1
  length  = 16
  special = false
}

data "template_file" "etcd-member" {
  count    = var.custom_ignition ? 0 : 1
  template = file("${path.module}/units/20-etcd-member.conf")
  vars = {
    node_name     = "${var.guest_hostname}-${format("%02d", count.index)}"
    private_ip    = "${var.guest_network_address_prefix}${format("%01d", count.index)}"
    cluster_token = random_string.token[0].result
  }
}
