variable "do_token" {}
variable "ssh_fingerprint" {}
variable "private_key" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

module "etcd" {
  source = "./etcd"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  private_key = "${var.private_key}"
}

output "etcd_ips" { value = "${module.etcd.public_ips}" }
