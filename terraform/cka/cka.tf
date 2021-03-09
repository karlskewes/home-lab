module "k8s_controllers" {
  source                        = "../modules/ubuntu/"
  qemu_uri                      = var.qemu_uri
  guest_count                   = 1
  guest_hostname                = "k8s-m-amd64"
  guest_network_mac_offset      = "32"
  guest_cpu                     = 2
  guest_memory                  = "2048"
  guest_os_volume_size          = 20000000000
  guest_domain_name             = var.guest_domain_name
  guest_user_name               = "karl"
  guest_user_ssh_authorized_key = var.guest_user_ssh_authorized_key
}

module "k8s_workers" {
  source                        = "../modules/ubuntu/"
  qemu_uri                      = var.qemu_uri
  guest_count                   = 1
  guest_hostname                = "k8s-w-amd64"
  guest_network_mac_offset      = "64"
  guest_cpu                     = 2
  guest_memory                  = "2048"
  guest_os_volume_size          = 20000000000
  guest_domain_name             = var.guest_domain_name
  guest_user_name               = "karl"
  guest_user_ssh_authorized_key = var.guest_user_ssh_authorized_key
}


