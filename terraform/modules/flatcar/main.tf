# Qcow2 base OS volume that can be shared by VM's (domain's)
resource "libvirt_volume" "os_base" {
  name   = "${var.guest_hostname}-os_base"
  source = var.guest_os_volume_source
}

# OS volume per guest VM
resource "libvirt_volume" "os" {
  count          = var.guest_count
  name           = "${var.guest_hostname}-${format("%02d", count.index)}-os.qcow2"
  base_volume_id = libvirt_volume.os_base.id
  pool           = var.guest_pool_name
  size           = var.guest_os_volume_size
}

# Secondary volume per guest VM
# resource "libvirt_volume" "secondary" {
#   count = var.guest_count
#   name  = "${var.guest_hostname}-${format("%02d", count.index)}-secondary.qcow2"
#   pool  = "usb${format("%02d", count.index)}"
#   size  = 100000000000
# }


resource "libvirt_ignition" "ignition" {
  count   = var.guest_count
  name    = "${var.guest_hostname}-${format("%02d", count.index)}-ignition"
  pool    = var.guest_pool_name
  content = var.custom_ignition ? var.ignition_config : element(data.ignition_config.ignition.*.rendered, count.index)
}

# domain/vm's to create
resource "libvirt_domain" "domain_vm" {
  count  = var.guest_count
  name   = "${var.guest_hostname}-${format("%02d", count.index)}"
  memory = var.guest_memory
  vcpu   = var.guest_cpu

  coreos_ignition = element(libvirt_ignition.ignition.*.id, count.index)
  fw_cfg_name     = "opt/org.flatcar-linux/config"

  network_interface {
    mac    = "${var.guest_network_mac_base}:${format("%02d", var.guest_network_mac_offset + count.index)}"
    bridge = var.guest_network_interface
    # requires qemu-agent but times out for me.
    # wait_for_lease = true
  }

  boot_device {
    dev = ["hd", "network"]
  }

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = element(libvirt_volume.os.*.id, count.index)
  }
  # disk {
  #   volume_id = element(libvirt_volume.secondary.*.id, count.index)
  # }
}

