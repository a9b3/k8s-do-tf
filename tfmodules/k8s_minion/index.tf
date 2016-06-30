variable "count" {}
variable "ssh_fingerprint" {}
variable "user_data" {}

resource "digitalocean_droplet" "k8s_minion" {
  count = "${var.count}"
  image = "coreos-stable"
  name = "k8s-minion-${count.index}"
  region = "sfo1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
  user_data = "${var.user_data}"
}

output "public_ips" { value = "${join(",", digitalocean_droplet.k8s_minion.*.ipv4_address)}" }
