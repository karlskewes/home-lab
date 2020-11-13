module "matchbox_vm" {
  source                       = "../modules/flatcar/"
  qemu_uri                     = var.qemu_uri
  guest_hostname               = "matchbox"
  guest_os_volume_source       = var.guest_os_volume_source
  guest_network_mac_offset     = "10"
  guest_network_address_prefix = "192.168.2.1"
  # guest_user_ssh_authorized_key = var.guest_user_ssh_authorized_key
  ignition_config = data.ignition_config.matchbox_ignition.rendered
  # depends_on                   = [data.ignition_config.matchbox_ignition]
}

data "ignition_config" "matchbox_ignition" {
  users = [
    data.ignition_user.matchbox.rendered,
  ]

  files = [
    data.ignition_file.matchbox_hostname.rendered
  ]

  networkd = [
    data.ignition_networkd_unit.matchbox.rendered,
  ]

  systemd = [
    data.ignition_systemd_unit.matchbox.rendered,
  ]
}

data "ignition_file" "matchbox_hostname" {
  filesystem = "root"
  path       = "/etc/hostname"
  mode       = 420

  content {
    content = "matchbox"
  }

}

data "ignition_user" "matchbox" {
  name   = var.guest_user_name
  groups = ["docker", "sudo"]

  ssh_authorized_keys = [var.guest_user_ssh_authorized_key]
}

data "ignition_networkd_unit" "matchbox" {
  name    = "00-wired.network"
  content = "[Match]\nName=eth0\n\n[Network]\nDHCP=ipv4"
}

data "ignition_systemd_unit" "matchbox" {
  name    = "matchbox.service"
  enabled = true
  content = data.template_file.matchbox_service.rendered
}

data "template_file" "matchbox_service" {
  template = file("./matchbox.service")
  vars = {
    matchbox_version = "v0.9.0"
  }
}
