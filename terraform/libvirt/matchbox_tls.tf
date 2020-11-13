# Matchbox TLS certificate generation
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs
# Heavy borrowed from: https://github.com/gruntwork-io/private-tls-cert
resource "tls_private_key" "ca" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm         = tls_private_key.ca.algorithm
  private_key_pem       = tls_private_key.ca.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 8760
  early_renewal_hours   = 1000
  allowed_uses          = ["cert_signing", "key_encipherment", "digital_signature", ]
  subject {
    common_name  = var.guest_domain_name
    organization = "Home lab"
  }
  provisioner "local-exec" {
    command = "echo '${tls_self_signed_cert.ca.cert_pem}' > ca.crt && chmod 600 ca.crt && chown ${var.guest_user_name} ca.crt"
  }
}

resource "tls_private_key" "matchbox" {
  algorithm = "RSA"
}

resource "tls_cert_request" "matchbox" {
  key_algorithm   = tls_private_key.matchbox.algorithm
  private_key_pem = tls_private_key.matchbox.private_key_pem
  dns_names       = ["matchbox-00.${var.guest_domain_name}"]
  ip_addresses    = ["192.168.2.10"] # fix remove hardcoded
  subject {
    common_name  = var.guest_domain_name
    organization = "Home lab"
  }
}

resource "tls_locally_signed_cert" "matchbox" {
  cert_request_pem      = tls_cert_request.matchbox.cert_request_pem
  ca_key_algorithm      = tls_private_key.ca.algorithm
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = "720"
  early_renewal_hours   = "168"
  allowed_uses          = ["key_encipherment", "digital_signature"]

}


resource "tls_private_key" "matchbox_client" {
  algorithm = "RSA"
  provisioner "local-exec" {
    command = "echo '${tls_private_key.matchbox_client.private_key_pem}' > matchbox_client.key && chmod 600 matchbox_client.key && chown ${var.guest_user_name} matchbox_client.key"
  }
}

resource "tls_cert_request" "matchbox_client" {
  key_algorithm   = tls_private_key.matchbox_client.algorithm
  private_key_pem = tls_private_key.matchbox_client.private_key_pem
  dns_names       = [var.guest_domain_name]
  subject {
    common_name  = var.guest_domain_name
    organization = "Home lab"
  }
}

resource "tls_locally_signed_cert" "matchbox_client" {
  cert_request_pem      = tls_cert_request.matchbox_client.cert_request_pem
  ca_key_algorithm      = tls_private_key.ca.algorithm
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = "720"
  early_renewal_hours   = "168"
  allowed_uses          = ["key_encipherment", "digital_signature"]
  provisioner "local-exec" {
    command = "echo '${tls_locally_signed_cert.matchbox_client.cert_pem}' > matchbox_client.crt && chmod 600 matchbox_client.crt && chown ${var.guest_user_name} matchbox_client.crt"
  }
}


