variable "do_token" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

module "etcd" {
  source = "./etcd"
  ssh_fingerprint = "${var.ssh_fingerprint}"
}

output "etcd_ips" { value = "${module.etcd.public_ips}" }
