terraform {
  required_providers {
    ignition = {
      source = "terraform-providers/ignition"
    }

    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }

    random = {
      source = "hashicorp/random"
    }

    template = {
      source = "hashicorp/template"
    }
  }

  required_version = ">= 0.13"
}
