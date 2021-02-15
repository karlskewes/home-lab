# validate up:
# 1. grpcurl -cacert ca.crt -cert matchbox_client.crt -key matchbox_client.key matchbox-00:8081 list
# 2. openssl s_client -connect matchbox-00:8081 -CAfile ca.crt -cert matchbox_client.crt -key matchbox_client.key
# 3. curl matchbox-00:8080/assets/flatcar

locals {
  flatcar_version  = "current"
  matchbox_version = "v0.9.0"
}

data "ignition_user" "ssh" {
  name   = var.guest_user_name
  groups = ["docker", "sudo"]

  ssh_authorized_keys = [var.guest_user_ssh_authorized_key]
}

module "matchbox_vm" {
  source                       = "../modules/flatcar/"
  guest_count                  = 1
  qemu_uri                     = var.qemu_uri
  custom_ignition              = true
  guest_hostname               = "matchbox"
  guest_os_volume_source       = var.guest_os_volume_source
  guest_network_mac_offset     = "10"
  guest_network_address_prefix = "192.168.2.1"
  # guest_user_ssh_authorized_key = var.guest_user_ssh_authorized_key
  ignition_config = data.ignition_config.matchbox_ignition.rendered
  # depends_on      = [tls_self_signed_cert.ca]
}

data "ignition_config" "matchbox_ignition" {
  directories = [
    data.ignition_directory.matchbox_etc.rendered,
    data.ignition_directory.matchbox_var_lib.rendered,
    data.ignition_directory.matchbox_var_lib_assets.rendered,
  ]
  files = [
    data.ignition_file.matchbox_hostname.rendered,
    data.ignition_file.matchbox_getflatcar.rendered,
    data.ignition_file.matchbox_tls_ca.rendered,
    data.ignition_file.matchbox_tls_cert.rendered,
    data.ignition_file.matchbox_tls_key.rendered,
  ]
  networkd = [data.ignition_networkd_unit.matchbox.rendered]
  systemd  = [data.ignition_systemd_unit.matchbox.rendered]
  users = [
    data.ignition_user.matchbox.rendered,
    data.ignition_user.ssh.rendered,
  ]
}

data "ignition_file" "matchbox_hostname" {
  filesystem = "root"
  path       = "/etc/hostname"
  mode       = 420
  content {
    content = "matchbox-00"
  }
}

data "ignition_networkd_unit" "matchbox" {
  name    = "00-wired.network"
  content = "[Match]\nName=eth0\n\n[Network]\nDHCP=ipv4"
}

data "ignition_user" "matchbox" {
  name           = "matchbox"
  no_create_home = true
  system         = true
  shell          = "/sbin/nologin"
  gecos          = 900
  uid            = 900
}

data "ignition_directory" "matchbox_etc" {
  filesystem = "root"
  path       = "/etc/matchbox"
  mode       = 448
  uid        = 900
  gid        = 900
}

data "ignition_directory" "matchbox_var_lib" {
  filesystem = "root"
  path       = "/var/lib/matchbox"
  mode       = 493
  uid        = 900
  gid        = 900
}

data "ignition_directory" "matchbox_var_lib_assets" {
  filesystem = "root"
  path       = "/var/lib/matchbox/assets"
  mode       = 493
  uid        = 900
  gid        = 900
}

data "ignition_systemd_unit" "matchbox" {
  name    = "matchbox.service"
  enabled = true
  content = data.template_file.matchbox_service.rendered
}

data "template_file" "matchbox_service" {
  template = file("./matchbox.service")
  vars = {
    flatcar_version  = local.flatcar_version
    matchbox_version = local.matchbox_version
  }
}

data "ignition_file" "matchbox_getflatcar" {
  filesystem = "root"
  mode       = 448
  uid        = 900
  gid        = 900
  path       = "/etc/matchbox/matchbox_getflatcar.sh"
  content {
    content = file("./matchbox_getflatcar.sh")
  }
}

data "ignition_file" "matchbox_tls_ca" {
  filesystem = "root"
  mode       = 384
  uid        = 900
  gid        = 900
  path       = "/etc/matchbox/ca.crt"
  content {
    content = tls_self_signed_cert.ca.cert_pem
  }
}

data "ignition_file" "matchbox_tls_cert" {
  filesystem = "root"
  mode       = 384
  uid        = 900
  gid        = 900
  path       = "/etc/matchbox/server.crt"
  content {
    content = tls_locally_signed_cert.matchbox.cert_pem
  }
}

data "ignition_file" "matchbox_tls_key" {
  filesystem = "root"
  mode       = 384
  uid        = 900
  gid        = 900
  path       = "/etc/matchbox/server.key"
  content {
    content = tls_private_key.matchbox.private_key_pem
  }
}
