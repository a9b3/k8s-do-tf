# Running Apps

```sh
kubectl cluster-info
```

If that returns something your cluster is up and running. And with a working kubernetes cluster you can deploy apps. 

http://kubernetes.io/docs/user-guide/connecting-applications/

## Deployment

A deployment configuration will allow you to specify what container image to run `spec.template` will be a pod definition.

```yaml
# hello-world-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: esayemm/hello-world:latest
        ports:
        - containerPort: 8080
```

You can now spin this deployment up and see the results, which will be 2 running hello-world containers that can be accessed within the kubernetes cluster only. You will need to do more to expose it to the external world.

```sh
# creates deployment
kubectl create -f hello-world-deployment.yaml

# see status of deployment
kubectl get deployment -l app=hello-world

# see the actual pods and get info about them
kubectl get pods -l app=hello-world -o yaml

# updating deployment
kubectl apply -f hello-world-deployment.yaml

# deleting deployment
kubectl delete deployment hello-world
```

You can try hitting the endpoint by getting the podIP and then sshing into one of the kubernetes nodes and running curl against the podIP.

```sh
# get podIP
kubectl get pods -l app=hello-world -o yaml | grep podIP

# ssh into one of the machines
ssh core@123.12.12.1

# inside one of the machines
curl http://<podIP>:8080
```

## Service

```yaml
# hello-world-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-world
  labels:
    run: hello-world
spec:
  ports:
  - port: 80 # port to serve service on
    targetPort: 8080 # containers port
    protocol: TCP
  selector:
    app: hello-world
  # if this is a websocket program and requires the load balancer to 
  # always send to the same pod
  # sessionAffinity: ClientIP
```

```sh
# creates deployment
kubectl create -f ./some.yaml

# see status of running pods
kubectl get pods -l labelKey=labelValue -o wide

# see status of deployment
kubectl get deployment

# get cluster internal pod ips
kubectl get pods -l labelKey=labelValue -o yaml | grep podIP

# update deployment
kubectl apply -f ./some.yaml

# delete deployment
kubectl delete deployment <name>
```

Two configurations necessary for deploying a service. Deployment config and Service config. Deployment is going to define the pods themselves and replicas, and Service will be the entry point and load balancer into the pods which will get a static ip for as long as the service is up regardless of pods.

## Exposing to outside cluster using NodePort

To make a service accessible from outside of the cluster we have to use NodePort, which will map a port on every node to a service. Add `type: NodePort` to the service spec.

```yaml
spec:
	type: NodePort
```

You can see what the NodePort that got assigned was by looking at the yaml

```sh
kubectl get services -l fooLabel=fooValue -o yaml | grep nodePort
```

Now you can hit that service from outside the cluster by hitting that port on any node ips.

```
curl http://<any cluster node ip>:<nodePort>
```

## Troubleshooting

If a node is showing status NotReady you can ssh into the affected node and do some doctoring. 

```sh
# list units
systemctl

# stop/start units
sudo systemctl stop foo.service
sudo systemctl start foo.service
```