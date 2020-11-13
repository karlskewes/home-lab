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

# cloud-init user_data template for user, package, other config - one per VM.
# Terraform will complain about `resource "template_file"` being deprecated,
# but for 0.11 at least `data "template_file"` doesn't handle count.
resource "template_file" "user_data" {
  count    = var.guest_count
  template = file("${path.module}/templates/user-data.tpl")

  vars = {
    fqdn                     = "${var.guest_hostname}-${format("%02d", count.index)}.${var.guest_domain_name}"
    hostname                 = "${var.guest_hostname}-${format("%02d", count.index)}"
    user_name                = var.guest_user_name
    user_ssh_authorized_keys = var.guest_user_ssh_authorized_key
    volume_size              = var.guest_os_volume_size
  }
}

# cloud-init meta_data so DHCP REQUEST's are made with VM's hostname
resource "template_file" "meta_data" {
  count    = var.guest_count
  template = file("${path.module}/templates/meta-data.tpl")

  vars = {
    local_hostname = "${var.guest_hostname}-${format("%02d", count.index)}"
    instance_id    = "${var.guest_hostname}-${format("%02d", count.index)}"
  }
}

# cloud-init network config to enable DHCP by default
data "template_file" "network_config" {
  template = file("${path.module}/templates/network-config.cfg")
}

# cloud-init complete iso image to mount in each VM
resource "libvirt_cloudinit_disk" "commoninit" {
  count          = var.guest_count
  name           = "${var.guest_hostname}-${format("%02d", count.index)}-commoninit.iso"
  meta_data      = element(template_file.meta_data.*.rendered, count.index)
  user_data      = element(template_file.user_data.*.rendered, count.index)
  network_config = data.template_file.network_config.rendered
  pool           = var.guest_pool_name
}

# domain/vm's to create
resource "libvirt_domain" "domain_vm" {
  count  = var.guest_count
  name   = "${var.guest_hostname}-${format("%02d", count.index)}"
  memory = var.guest_memory
  vcpu   = var.guest_cpu

  cloudinit = element(libvirt_cloudinit_disk.commoninit.*.id, count.index)

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
}

