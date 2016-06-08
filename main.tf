variable "do_token" {}
variable "ssh_fingerprint" {}
variable "private_key" {}

variable "etcd_discovery_token" {}
variable "etcd_count" {}
variable "k8s_version" {}
variable "k8s_service_ip" {}
variable "pod_network" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

/*****************************************************************************
 *  etcd
 ****************************************************************************/

resource "template_file" "etcd" {
  template = "${file("${path.module}/templates/etcd_user-data")}"

  vars {
    etcd_discovery_token = "${var.etcd_discovery_token}"
  }
}

module "etcd" {
  source = "./etcd"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  count = "${var.etcd_count}"
  private_key = "${var.private_key}"
  user_data = "${template_file.etcd.rendered}"
}

/*****************************************************************************
 *  k8s_master
 ****************************************************************************/

resource "template_file" "k8s_master" {
  template = "${file("${path.module}/templates/k8s_master_user-data")}"

  vars {
    k8s_version = "${var.k8s_version}"
    k8s_service_ip = "${var.k8s_service_ip}"
    etcd_discovery_token = "${var.etcd_discovery_token}"
    pod_network = "${var.pod_network}"
    etcd_ips = "${module.etcd.public_ips}"

    ca_pem = "${file("${path.module}/certs/ca.pem")}"
    ca_key_pem = "${file("${path.module}/certs/ca-key.pem")}"
  }
}

module "k8s_master" {
  source = "./k8s_master"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  private_key = "${var.private_key}"
  etcd_ips = "${module.etcd.public_ips}"
  user_data = "${template_file.k8s_master.rendered}"
}

output "etcd_ips" { value = "${module.etcd.public_ips}" }
output "k8s_ip" { value = "${module.k8s_master.public_ip}" }
