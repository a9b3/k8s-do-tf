variable "ssh_fingerprint" {}
variable "count" {
  default = "2"
}

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
  user_data = "${file("${path.module}/user-data")}"
}

output "public_ips" { value = "${join(",", digitalocean_droplet.etcd.*.ipv4_address)}" }
