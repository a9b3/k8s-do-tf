variable "ssh_fingerprint" {}
variable "private_key" {}
variable "etcd_ips" {}

resource "digitalocean_droplet" "k8s_master" {
  image = "coreos-stable"
  name = "k8s_master"
  region = "sfo1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
  user_data = "${file("${path.module}/user-data")}"
}

output "public_ip" { value = "${digitalocean_droplet.k8s_master.ipv4_address}" }
