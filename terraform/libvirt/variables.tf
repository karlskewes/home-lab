variable "qemu_uri" {
  description = "QEMU Connection URI"
}

variable "guest_os_volume_source" {
  description = "Source of OS volume to use for VM"
}

variable "guest_user_name" {
  description = "User to be added to guest"
}

variable "guest_user_ssh_authorized_key" {
  description = "Public SSH Key to be added to guest"
}
