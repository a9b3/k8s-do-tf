variable "ssh_fingerprint" {}
variable "private_key" {}
variable "user_data" {}
variable "count" {}

resource "digitalocean_droplet" "etcd" {
  count = "${var.count}"
  image = "coreos-stable"
  name = "etcd-${count.index}"
  region = "sfo1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
  user_data = "${var.user_data}"
}

output "public_ips" { value = "${join(",", digitalocean_droplet.etcd.*.ipv4_address)}" }
