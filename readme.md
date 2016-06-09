# Kubernetes on DigitalOcean using Terraform

Use for prod at your own risk, this cluster isn't secure. PRs for better security are welcomed.

## Prereqs

- [hbs-templater](https://github.com/esayemm/hbs-templater) `npm i -g hbs-templater`
- [cfssl](https://github.com/cloudflare/cfssl)
- [terraform](https://www.terraform.io/downloads.html)
- [kubectl](http://kubernetes.io/docs/getting-started-guides/binary_release/#prebuilt-binary-release)

Once you have those binaries installed you are ready to go

## Get Started

### Init cluster config

Set default values inside `just_doit.sh`.

This should only be ran once per cluster. Set two env variables when running `just_doit.sh` for the first time.

- DO_TOKEN - digital ocean token
- PRIVATE_KEY - path to digital ocean private key

```sh
DO_TOKEN=footoken PRIVATE_KEY=~/.ssh/do_rsa ./just_doit.sh
```

This will create terraform.tfvars with the cluster information.

### Spin up nodes 

```sh
terraform get
terraform plan
terraform apply
```

This will output the master node ip for setting up kubectl.

### Setup kubectl

```sh
./setup_kubectl.sh <master node ip>
```

Now you should be able to use kubectl on your local machine to interact with the cluster. You might have to wait a couple minutes for servers to finish provisioning.

```sh
kubectl cluster-info
```