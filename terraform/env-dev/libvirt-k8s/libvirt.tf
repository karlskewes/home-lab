# Provider details
provider "libvirt" {
  uri = "${var.uri_method}://${var.uri_username}@${var.uri_hostname}/system"
}

terraform {
  required_version = ">= 0.11.7"

  # Add your remote state here
  #  backend "s3" {
  #    region         = "ap-southeast-2"
  #    bucket         = "yourname-env-tfstate-backend"
  #    key            = "libvirt.tfstate"
  #    dynamodb_table = "yourname-env-tfstate-backend-lock"
  #    encrypt        = true
  #  }
}
