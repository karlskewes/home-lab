# Variables for environment

# KVM Host Connection

variable "qemu_uri" {
  description = "QEMU Connection URI"
  default     = "qemu:///system"
  type        = string
}

# Environment Variables

variable "guest_count" {
  description = "Number of domains to create"
  default     = 1
  type        = number
}

# Guest

variable "guest_os_volume_size" {
  description = "Size in Bytes of OS volume will grow source to"
  default     = 10000000000
  type        = number
}

# wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.bz2
variable "guest_os_volume_source" {
  description = "Source of OS volume to use for VM"
  default     = "flatcar_production_qemu_image.img"
  type        = string
}

variable "guest_user_name" {
  description = "User to be added to guest"
  default     = "core"
  type        = string
}

variable "guest_user_ssh_authorized_key" {
  description = "Public SSH Key to be added to guest"
  default     = "ssh-rsa some-string-goes-here"
  type        = string
}

variable "guest_domain_name" {
  description = "Guest VM domain name"
  default     = "local"
  type        = string
}

variable "guest_hostname" {
  description = "Guest VM hostname"
  default     = "host"
  type        = string
}

variable "guest_memory" {
  description = "Guest VM Memory amount"
  default     = 1024
  type        = number
}

variable "guest_cpu" {
  description = "Guest CPU cores"
  default     = 1
  type        = number
}

variable "guest_network_mac_base" {
  description = "Guest Network MAC Address base 5 pairs, 6th pair calculated"
  default     = "52:54:00:00:00"
  type        = string
}

variable "guest_network_address_prefix" {
  description = "Guest Network Address Prefix"
  default     = "192.168.1."
  type        = string
}

variable "guest_network_mac_offset" {
  description = "Guest Network MAC Address last pair offset from 00"
  default     = "0"
  type        = string
}

variable "guest_network_interface" {
  description = "Guest network interface"
  default     = "br0"
  type        = string
}

variable "guest_pool_name" {
  description = "Guest pool name"
  default     = "default"
  type        = string
}

variable "ignition_config" {
  description = "Ignition Configuration"
}

variable "custom_ignition" {
  description = "Custom Ignition Configuration to override default"
  default     = false
  type        = bool
}
