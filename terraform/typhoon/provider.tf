provider "matchbox" {
  endpoint    = "matchbox-00.k8s.garagedori.com:8081"
  client_cert = file("../matchbox/matchbox_client.crt")
  client_key  = file("../matchbox/matchbox_client.key")
  ca          = file("../matchbox/ca.crt")
}

provider "ct" {}

terraform {
  required_version = ">= 0.13"

  required_providers {
    # typhoon
    ct = {
      source  = "poseidon/ct"
      version = "0.6.1"
    }
    matchbox = {
      source  = "poseidon/matchbox"
      version = "0.4.1"
    }
  }
}


