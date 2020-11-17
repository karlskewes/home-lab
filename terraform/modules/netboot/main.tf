resource "libvirt_volume" "os" {
  count = var.guest_count
  name  = "${var.guest_hostname}-${format("%02d", count.index)}-os.qcow2"
  pool  = var.guest_pool_name
  size  = var.guest_os_volume_size
}

resource "libvirt_domain" "domain_vm" {
  count  = var.guest_count
  name   = "${var.guest_hostname}-${format("%02d", count.index)}"
  memory = var.guest_memory
  vcpu   = var.guest_cpu

  network_interface {
    mac    = "${var.guest_network_mac_base}:${format("%02d", var.guest_network_mac_offset + count.index)}"
    bridge = var.guest_network_interface
  }

  boot_device {
    dev = ["hd", "network"] # boot hd if already setup, else PXE boot
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
    scsi      = "true" # present as 'sda' device instead of 'vda'
  }
}

