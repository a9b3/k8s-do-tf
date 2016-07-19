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
variable "domain_name" {
  default = "staging-samlau.us"
}

provider "digitalocean" {
  token = "${var.do_token}"
}

/*****************************************************************************
 *  etcd
 ****************************************************************************/

resource "template_file" "etcd" {
  template = "${file("${path.module}/tftemplates/etcd_user-data")}"

  vars {
    etcd_discovery_token = "${var.etcd_discovery_token}"
  }
}

module "etcd" {
  source = "./tfmodules/etcd"

  count = "${var.etcd_count}"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  user_data = "${template_file.etcd.rendered}"
}

/*****************************************************************************
 *  k8s_master
 ****************************************************************************/

resource "template_file" "k8s_master" {
  template = "${file("${path.module}/tftemplates/k8s_master_user-data")}"

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
    admin_key_pem = "${file("${path.module}/certs/admin-key.pem")}"
    admin_pem = "${file("${path.module}/certs/admin.pem")}"
  }
}

module "k8s_master" {
  source = "./tfmodules/k8s_master"

  count = "${var.k8s_master_count}"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  user_data = "${template_file.k8s_master.rendered}"
}

/*****************************************************************************
 *  k8s_minion
 ****************************************************************************/

resource "template_file" "k8s_minion" {
  template = "${file("${path.module}/tftemplates/k8s_minion_user-data")}"

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
  source = "./tfmodules/k8s_minion"

  count = "${var.k8s_minion_count}"
  ssh_fingerprint = "${var.ssh_fingerprint}"
  user_data = "${template_file.k8s_minion.rendered}"
}

/*****************************************************************************
 *  external facing load balancer
 ****************************************************************************/

resource "template_file" "load_balancer" {
  template = "${file("${path.module}/tftemplates/load_balancer_user-data")}"

  vars {
    etcd_discovery_token = "${var.etcd_discovery_token}"
    etcd_ips = "${join(",", formatlist("http://%s:2379", split(",", module.etcd.public_ips)))}"
    domain_name = "${var.domain_name}"
  }
}

module "load_balancer" {
  source = "./tfmodules/load_balancer"

  ssh_fingerprint = "${var.ssh_fingerprint}"
  user_data = "${template_file.load_balancer.rendered}"
}

/*****************************************************************************
 *  database
 ****************************************************************************/

resource "digitalocean_droplet" "database" {
  image = "ubuntu-14-04-x64"
  name = "database"
  region = "sfo1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
}

output "etcd_ips" { value = "${module.etcd.public_ips}" }
output "k8s_master_ips" { value = "${module.k8s_master.public_ips}" }
output "k8s_minion_ips" { value = "${module.k8s_minion.public_ips}" }
output "load_balancer_ip" { value = "${module.load_balancer.public_ip}" }
output "database_ip" { value = "${digitalocean_droplet.database.ipv4_address}" }
