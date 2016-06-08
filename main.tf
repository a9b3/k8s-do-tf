variable "do_token" {}
variable "ssh_fingerprint" {}
variable "private_key" {}
variable "etcd_count" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

module "etcd" {
  source = "./etcd"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  count = "${var.etcd_count}"
  private_key = "${var.private_key}"
}

resource "null_resource" "etcd" {
  provisioner "local-exec" {
    command = "./scripts/k8s_master.sh ${module.etcd.public_ips}"
  }
}

/* module "k8s_master" { */
/*   source = "./k8s_master" */
/*   ssh_fingerprint = "${var.ssh_fingerprint}" */
/*   private_key = "${var.private_key}" */
/*   etcd_ips = "${module.etcd.public_ips}" */
/* } */

output "etcd_ips" { value = "${module.etcd.public_ips}" }
/* output "k8s_master_ip" { value = "${module.k8s_master.public_ip}" } */
