module "typhoon" {
  source = "git::https://github.com/poseidon/typhoon//bare-metal/flatcar-linux/kubernetes?ref=v1.19.4"

  # bare-metal
  cluster_name           = "typhoon"
  matchbox_http_endpoint = "http://matchbox-00.k8s.garagedori.com:8080"
  os_channel             = "flatcar-stable"
  os_version             = "2605.7.0"
  cached_install         = true

  # set to http only if you cannot chainload to iPXE firmware with https support
  download_protocol = "http"

  # configuration
  k8s_domain_name    = var.guest_domain_name
  ssh_authorized_key = var.guest_user_ssh_authorized_key

  # machines
  controllers = [
    {
      name   = "k8s-m-amd64-00"
      mac    = "52:54:00:00:00:32"
      domain = "k8s-m-amd64-00.${var.guest_domain_name}"
    },
    {
      name   = "k8s-m-amd64-01"
      mac    = "52:54:00:00:00:33"
      domain = "k8s-m-amd64-01.${var.guest_domain_name}"
    },
    {
      name   = "k8s-m-amd64-02"
      mac    = "52:54:00:00:00:34"
      domain = "k8s-m-amd64-02.${var.guest_domain_name}"
    }
  ]
  workers = [
    {
      name   = "k8s-w-amd64-00"
      mac    = "52:54:00:00:00:64"
      domain = "k8s-w-amd64-00.${var.guest_domain_name}"
    },
    {
      name   = "k8s-w-amd64-01"
      mac    = "52:54:00:00:00:65"
      domain = "k8s-w-amd64-01.${var.guest_domain_name}"
    },
    {
      name   = "k8s-w-amd64-02"
      mac    = "52:54:00:00:00:66"
      domain = "k8s-w-amd64-02.${var.guest_domain_name}"
    }
  ]

  worker_node_labels = {
    "k8s-w-amd64-00" = ["topology.kubernetes.io/zone=a"],
    "k8s-w-amd64-01" = ["topology.kubernetes.io/zone=b"],
    "k8s-w-amd64-02" = ["topology.kubernetes.io/zone=c"],
  }
}


resource "local_file" "kubeconfig-typhoon" {
  content  = module.typhoon.kubeconfig-admin
  filename = pathexpand("~/.kube/typhoon.yml")
}
