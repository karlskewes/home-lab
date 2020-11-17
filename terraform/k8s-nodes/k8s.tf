# (i)PXE booted VM's need more memory

module "k8s_controllers" {
  source                   = "../modules/netboot/"
  qemu_uri                 = var.qemu_uri
  guest_count              = 3
  guest_hostname           = "k8s-m-amd64"
  guest_network_mac_offset = "32"
  guest_memory             = "2048"
}

module "k8s_workers" {
  source                   = "../modules/netboot/"
  qemu_uri                 = var.qemu_uri
  guest_count              = 3
  guest_hostname           = "k8s-w-amd64"
  guest_network_mac_offset = "64"
  guest_memory             = "2048"
}


