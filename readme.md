# Kubernetes on DigitalOcean using Terraform


## Prereqs

- [hbs-templater](https://github.com/esayemm/hbs-templater) `npm i -g hbs-templater`
- [cfssl](https://github.com/cloudflare/cfssl)
- [terraform](https://www.terraform.io/downloads.html)

Once you have those binaries installed you are ready to go

## Get Started

### Init cluster config

Set two env variables when running `just_doit.sh` for the first time.

- DO_TOKEN - digital ocean token
- PRIVATE_KEY - path to digital ocean private key

```sh
DO_TOKEN=footoken PRIVATE_KEY=~/.ssh/do_rsa ./just_doit.sh
```

This will create terraform.tfvars

### Spin up nodes 

```sh
terraform plan
terraform apply
```

This will output the master node ip for setting up kubectl.

### Setup kubectl

```sh
./setup_kubectl.sh <master node ip>
```

Now you should be able to use kubectl on your local machine to interact with the cluster.

```sh
kubectl cluster-info
```