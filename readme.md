# Kubernetes on DigitalOcean using Terraform


## Prereqs

- [hbs-templater](https://github.com/esayemm/hbs-templater) `npm i -g hbs-templater`
- [cfssl](https://github.com/cloudflare/cfssl)
- [terraform](https://www.terraform.io/downloads.html)

Once you have those binaries installed you are ready to go

## The Script

Set two env variables when running `just_doit.sh` for the first time.

- DO_TOKEN - digital ocean token
- PRIVATE_KEY - path to digital ocean private key

```sh
DO_TOKEN=footoken PRIVATE_KEY=~/.ssh/do_rsa ./just_doit.sh
```

This will create terraform.tfvars