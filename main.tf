variable "do_token" {}
variable "ssh_fingerprint" {}

variable "dns_service_ip" {}
variable "etcd_count" {}
variable "etcd_discovery_token" {}
variable "k8s_master_count" {}
variable "k8s_minion_count" {}
variable "k8s_service_ip" {}
variable "k8s_service_ip_range" {}
variable "k8s_version" {}
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

  count = "${var.etcd_count}"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  user_data = "${template_file.etcd.rendered}"
}

/*****************************************************************************
 *  k8s_master
 ****************************************************************************/

resource "template_file" "k8s_master" {
  template = "${file("${path.module}/templates/k8s_master_user-data")}"

  vars {
    etcd_discovery_token = "${var.etcd_discovery_token}"
    etcd_ips = "${join(",", formatlist("http://%s:2379", split(",", module.etcd.public_ips)))}"
    k8s_master_count = "${var.k8s_master_count}"
    k8s_service_ip = "${var.k8s_service_ip}"
    k8s_service_ip_range = "${var.k8s_service_ip_range}"
    k8s_version = "${var.k8s_version}"
    pod_network = "${var.pod_network}"

    ca_key_pem = "${file("${path.module}/certs/ca-key.pem")}"
    ca_pem = "${file("${path.module}/certs/ca.pem")}"
  }
}

module "k8s_master" {
  source = "./k8s_master"

  count = "${var.k8s_master_count}"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  user_data = "${template_file.k8s_master.rendered}"
}

/*****************************************************************************
 *  k8s_minion
 ****************************************************************************/

resource "template_file" "k8s_minion" {
  template = "${file("${path.module}/templates/k8s_minion_user-data")}"

  vars {
    dns_service_ip = "${var.dns_service_ip}"
    etcd_discovery_token = "${var.etcd_discovery_token}"
    etcd_ips = "${join(",", formatlist("http://%s:2379", split(",", module.etcd.public_ips)))}"
    k8s_minion_count = "${var.k8s_minion_count}"
    k8s_service_ip = "${var.k8s_service_ip}"
    k8s_service_ip_range = "${var.k8s_service_ip_range}"
    k8s_version = "${var.k8s_version}"
    master_ip = "${module.k8s_master.public_ips}"
    pod_network = "${var.pod_network}"

    ca_pem = "${file("${path.module}/certs/ca.pem")}"
    ca_key_pem = "${file("${path.module}/certs/ca-key.pem")}"
  }
}

module "k8s_minion" {
  source = "./k8s_minion"

  count = "${var.k8s_minion_count}"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  user_data = "${template_file.k8s_minion.rendered}"
}

/* output "template" { value = "${template_file.k8s_master.rendered}" } */
output "etcd_ips" { value = "${module.etcd.public_ips}" }
output "k8s_master_ips" { value = "${module.k8s_master.public_ips}" }
output "k8s_minion_ips" { value = "${module.k8s_minion.public_ips}" }
