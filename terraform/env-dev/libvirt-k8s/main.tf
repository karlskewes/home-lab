# TODO: refactor to single VM module

# Qcow2 base volume that can be shared by VM's (domain's)
resource "libvirt_volume" "volume_base" {
  name   = "${var.guest_hostname}-volume_base"
  source = "${var.volume_source}"
}

# Volume per guest VM
resource "libvirt_volume" "volume" {
  count          = "${var.guest_count}"
  name           = "${var.guest_hostname}-${format("%02d", count.index+1)}-volume.qcow2"
  base_volume_id = "${libvirt_volume.volume_base.id}"
  pool           = "${var.guest_pool_name}"
  size           = "${var.volume_size}"
}

# cloud-init user_data template for user, package, other config - one per VM.
# Terraform will complain about `resource "template_file"` being deprecated,
# but for 0.11 at least `data "template_file"` doesn't handle count.
resource "template_file" "user_data" {
  count    = "${var.guest_count}"
  template = "${file("${path.module}/templates/user-data.tpl")}"

  vars {
    fqdn                     = "${var.guest_hostname}-${format("%02d", count.index+1)}.${var.guest_domain_name}"
    hostname                 = "${var.guest_hostname}-${format("%02d", count.index+1)}"
    user_name                = "${var.guest_user_name}"
    user_ssh_authorized_keys = "${var.guest_user_ssh_authorized_key}"
    volume_size              = "${var.volume_size}"
  }
}

# cloud-init meta_data so DHCP REQUEST's are made with VM's hostname
resource "template_file" "meta_data" {
  count    = "${var.guest_count}"
  template = "${file("${path.module}/templates/meta-data.tpl")}"

  vars {
    local_hostname = "${var.guest_hostname}-${format("%02d", count.index+1)}"
    instance_id    = "${var.guest_hostname}-${format("%02d", count.index+1)}"
  }
}

# cloud-init network config to enable DHCP by default
data "template_file" "network_config" {
  template = "${file("${path.module}/templates/network-config.cfg")}"
}

# cloud-init complete iso image to mount in each VM
resource "libvirt_cloudinit_disk" "commoninit" {
  count          = "${var.guest_count}"
  name           = "${var.guest_hostname}-${format("%02d", count.index+1)}-commoninit.iso"
  meta_data      = "${element(template_file.meta_data.*.rendered, count.index)}"
  user_data      = "${element(template_file.user_data.*.rendered, count.index)}"
  network_config = "${data.template_file.network_config.rendered}"
  pool           = "${var.guest_pool_name}"
}

# domain/vm's to create
resource "libvirt_domain" "domain_vm" {
  count  = "${var.guest_count}"
  name   = "${var.guest_hostname}-${format("%02d", count.index+1)}"
  memory = "${var.guest_memory}"
  vcpu   = "${var.guest_cpu}"

  cloudinit = "${element(libvirt_cloudinit_disk.commoninit.*.id, count.index)}"

  network_interface {
    mac    = "${var.guest_network_mac_base}:${format("%02d", (var.guest_network_mac_offset + count.index + 1))}"
    bridge = "${var.guest_network_interface}"

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
    volume_id = "${element(libvirt_volume.volume.*.id, count.index)}"
  }
}
