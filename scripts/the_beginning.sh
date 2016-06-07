# Pin this script to it's location
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

###############################################################################
# clean slate
###############################################################################
cd ../
terraform destroy
cd scripts

###############################################################################
# config.env file
###############################################################################
echo ""
ETCD_CLUSTER_SIZE=2
MASTER_CLUSTER_SIZE=1
MINION_CLUSTER_SIZE=2

# Flannel range for docker containers
POD_NETWORK='10.2.0.0/16'
SERVICE_IP_RANGE='10.3.0.0/24'
KUBERNETES_SERVICE_IP='10.3.0.1'
DNS_SERVICE_IP='10.3.0.10'

echo "Getting new discovery token..."
_ETCD_DISCOVERY_URL=$(curl -s https://discovery.etcd.io/new?size=$ETCD_CLUSTER_SIZE)
ETCD_DISCOVERY_TOKEN=${_ETCD_DISCOVERY_URL##*/}
echo "Discovery token is ${ETCD_DISCOVERY_TOKEN}"
echo ""

echo "Getting kubernetes stable version..."
K8S_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
echo "Kubernetes Stable Version is ${K8S_VERSION}"
echo ""

CONFIG_PARAMS="{
  \"ETCD_CLUSTER_SIZE\": \"$ETCD_CLUSTER_SIZE\",
  \"ETCD_DISCOVERY_TOKEN\": \"$ETCD_DISCOVERY_TOKEN\",
  \"MASTER_CLUSTER_SIZE\": \"$MASTER_CLUSTER_SIZE\",
  \"MINION_CLUSTER_SIZE\": \"$MINION_CLUSTER_SIZE\",
  \"K8S_VERSION\": \"$K8S_VERSION\",
  \"POD_NETWORK\": \"$POD_NETWORK\",
  \"SERVICE_IP_RANGE\": \"$SERVICE_IP_RANGE\",
  \"KUBERNETES_SERVICE_IP\": \"$KUBERNETES_SERVICE_IP\",
  \"DNS_SERVICE_IP\": \"$DNS_SERVICE_IP\"
}"

echo "Generating config.env with the following params..."
echo ""
echo "$CONFIG_PARAMS"
echo ""
hbs-templater compile --params "$CONFIG_PARAMS" --input ./config_tpl --output . -l --overwrite

echo "Sourcing config.env"
source ./config.env
echo ""

###############################################################################
# etcd user-data
###############################################################################

ETCD_PARAMS="{
  \"CLUSTER_SIZE\": \"$ETCD_CLUSTER_SIZE\",
  \"ETCD_DISCOVERY_TOKEN\": \"$ETCD_DISCOVERY_TOKEN\"
}"

echo "Generating etcd user-data with the following params..."
echo ""
echo "$ETCD_PARAMS"
echo ""
hbs-templater compile --params "$ETCD_PARAMS" \
  --input ./templates/etcd \
  --output ../etcd \
  -l --overwrite

echo ""
echo "Creating etcd nodes..."
echo ""
cd ../
terraform plan
terraform apply -var "count=$ETCD_CLUSTER_SIZE"
cd scripts
