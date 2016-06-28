variable "ssh_fingerprint" {}
variable "user_data" {}

resource "digitalocean_droplet" "load_balancer" {
  image = "coreos-stable"
  name = "load_balancer"
  region = "sfo1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
  user_data = "${var.user_data}"
}

output "public_ip" { value = "${digitalocean_droplet.load_balancer.ipv4_address}" }
