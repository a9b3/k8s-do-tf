variable "ssh_fingerprint" {}
variable "private_key" {}
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

  connection {
    user = "core"
    private_key = "${file("${var.private_key}")}"
  }

  /* provisioner "local-exec" { */
  /*   command = "${digitalocean_droplet.etcd.module_path}/generate_and_sign_cert.sh hi hi" */
  /*   command = "./generate_and_sign_cert.sh hi hi" */
  /* } */

  provisioner "file" {
    source = "${path.module}/../certs"
    destination = "/etc/ssl"
  }

  /* provisioner "remote-exec" { */
  /*   inline = [ */
  /*     "cp ~/test.txt ~/foo.txt" */
  /*   ] */
  /* } */
}

output "public_ips" { value = "${join(",", digitalocean_droplet.etcd.*.ipv4_address)}" }
