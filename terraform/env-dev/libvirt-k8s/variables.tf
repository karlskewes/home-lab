# Variables for environment

# KVM Host Connection

variable "uri_method" {
  description = "Method will connect to Qemu KVM host"
  default     = "qemu"
}

variable "uri_username" {
  description = "Username to use when connecting via SSH"
}

variable "uri_hostname" {
  description = "KVM Host to connect to"
  default     = "localhost"
}

# Environment Variables

variable "guest_count" {
  description = "Number of domains to create"
  default     = 1
}

# Guest

variable "os_volume_size" {
  description = "Size in Bytes of OS volume will grow source to"
  default     = 10000000000
}

variable "os_volume_source" {
  description = "Source of OS volume to use for VM"
  default     = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
}

variable "guest_user_name" {
  description = "User to be added to guest"
}

variable "guest_user_ssh_authorized_key" {
  description = "Public SSH Key to be added to guest"
}

variable "guest_domain_name" {
  description = "Guest VM domain name"
  default     = "local"
}

variable "guest_hostname" {
  description = "Guest VM hostname"
  default     = "host"
}

variable "guest_memory" {
  description = "Guest VM Memory amount"
  default     = 1024
}

variable "guest_cpu" {
  description = "Guest CPU cores"
  default     = 1
}

variable "guest_network_mac_base" {
  description = "Guest Network MAC Address base 5 pairs, 6th pair calculated"
  default     = "52:54:00:00:00"
}

variable "guest_network_mac_offset" {
  description = "Guest Network MAC Address last pair offset from 00"
  default     = "0"
}

variable "guest_network_interface" {
  description = "Guest network interface"
  default     = "br0"
}

variable "guest_pool_name" {
  description = "Guest pool name"
  default     = "default"
}
