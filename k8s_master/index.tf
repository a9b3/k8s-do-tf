variable "ssh_fingerprint" {}
variable "private_key" {}
variable "etcd_ips" {}
variable "user_data" {}
variable "k8s_master_count" {}

resource "digitalocean_droplet" "k8s_master" {
  count = "${var.k8s_master_count}"
  image = "coreos-stable"
  name = "k8s-master"
  region = "sfo1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
  user_data = "${var.user_data}"
}

output "public_ips" { value = "${join(",", digitalocean_droplet.k8s_master.*.ipv4_address)}" }
