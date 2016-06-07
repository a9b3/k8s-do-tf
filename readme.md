# Kubernetes on DigitalOcean using Terraform

## Packer

Packer is used to build images.

## Prereqs

- [hbs-templater](https://github.com/esayemm/hbs-templater) `npm i -g hbs-templater`
- [cfssl](https://github.com/cloudflare/cfssl)
- [terraform](https://www.terraform.io/downloads.html)
- [packer](https://www.packer.io/downloads.html)

Create a `terraform.tfvars` file in project root and replace values.

**do_token** Get this from digitalocean web dashboard, click on api > generate new token. Save this somewhere private. I saved it in a private env file on my local machine.

**ssh_fingerprint** [Follow these instructions](https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets) Assuming you saved the key as `~/.ssh/do_rsa` run this command to get the ssh fingerprint `ssh-keygen -E md5 -lf ~/.ssh/do_rsa.pub | awk '{print $2}' | sed "s/^MD5://"`. Put this value into the tfvars file.

```
# terraform.tfvars
do_token = "replace"
ssh_fingerprint = "replace"
```

Once you have those binaries installed you are ready to go