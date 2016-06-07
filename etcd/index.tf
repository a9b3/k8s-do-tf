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

  /* provisioner "remote-exec" { */
  /*   inline = [ */
  /*     "mkdir -p ~/etc/ssl", */
  /*     "mkdir -p ~/etc/bin" */
  /*   ] */
  /* } */
  /*  */
  /* provisioner "file" { */
  /*   source = "./certs" */
  /*   destination = "~/etc/ssl" */
  /* } */
  /*  */
  /* provisioner "file" { */
  /*   source = "./etcd/generate_and_sign_cert.sh" */
  /*   destination = "~/etc/bin/generate_and_sign_cert.sh" */
  /* } */
  /*  */
  /* provisioner "remote-exec" { */
  /*   inline = [ */
  /*     "export PATH=$PATH:~/etc/bin", */
  /*     "curl -s -L -o ~/etc/bin/cfssl https://pkg.cfssl.org/R1.1/cfssl_linux-amd64", */
  /*     "curl -s -L -o ~/etc/bin/cfssljson https://pkg.cfssl.org/R1.1/cfssljson_linux-amd64", */
  /*     "chmod +x ~/etc/bin/cfssl", */
  /*     "chmod +x ~/etc/bin/cfssljson", */
  /*     "chmod +x ~/etc/bin/generate_and_sign_cert.sh", */
  /*     "~/etc/bin/generate_and_sign_cert.sh ${self.name} ${digitalocean_droplet.etcd.ipv4_address}" */
  /*   ] */
  /* } */
}

output "public_ips" { value = "${join(",", digitalocean_droplet.etcd.*.ipv4_address)}" }
