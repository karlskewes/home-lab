# Provider details
provider "libvirt" {
  uri = var.qemu_uri
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }

    template = {
      source = "hashicorp/template"
    }
    ignition = {
      source = "terraform-providers/ignition"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}
