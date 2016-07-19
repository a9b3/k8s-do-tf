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

**IMPORTANT**: EDIT configs in `just_doit.sh` starting line 62. ALSO edit `load_balancer_user-data` to point at the correct kontinuum server, or take it out if none.

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

This will output the master node ip for setting up kubectl. Copy master node ip.

### Setup kubectl

```sh
./setup_kubectl.sh
```

Now you should be able to use kubectl on your local machine to interact with the cluster. You might have to wait a couple minutes for servers to finish provisioning.

```sh
kubectl cluster-info
```

## What you get

If you didn't edit anything, 2 etcd nodes, 1 master kubernetes node, 3 minion kubernetes node, and one load balancer node.

## External Load Balancer

The load balancer node is listening for changes in etcd for kubernetes services with exposed nodePort, you will have to get your own domain name and set it up in digital ocean networking.

ex.

If you want a hello-world server that you can reach via hello-world.yourdomainname.com.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-world
  labels:
    run: hello-world
    # specify subdomain
    subdomain: hello-world
```

Look in examples for more details.

You can set subdomain to `index` and that will resolve to yourdomainname.com

## Kontinuum

To set up kontinuum for continious deployment read more [here](https://github.com/esayemm/kontinuum)

## Databases

```sh
scp ./setup_database.sh root@<database_ip>:~/setup_database.sh
ssh root@<database_ip>
./setup_database.sh
vim /etc/mongod.conf  
# comment out bindIp
service mongod restart

vim /etc/redis/redis.conf
# comment out bind
service redis-server restart
```
