# don't use this script directly
# this script is used by terraform main.tf

# Pin this script to it's location
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

echo "Sourcing config.env"
source ./config.env
echo ""

###############################################################################
# k8s master user-data
###############################################################################

# Get this from main.tf
ETCD_CLUSTER_NODE_IPS=$1

MASTER_PARAMS="{
  \"ETCD_CLUSTER_NODE_IPS\": \"$ETCD_CLUSTER_NODE_IPS\",
  \"CLUSTER_SIZE\": \"$MASTER_CLUSTER_SIZE\",
  \"ETCD_DISCOVERY_TOKEN\": \"$ETCD_DISCOVERY_TOKEN\",
  \"K8S_VERSION\": \"$K8S_VERSION\",
  \"POD_NETWORK\": \"$POD_NETWORK\",
  \"SERVICE_IP_RANGE\": \"$SERVICE_IP_RANGE\",
  \"KUBERNETES_SERVICE_IP\": \"$KUBERNETES_SERVICE_IP\",
  \"DNS_SERVICE_IP\": \"$DNS_SERVICE_IP\"
}"

echo ""
echo "Generating k8s master user-data with the following params..."
echo ""
echo "$MASTER_PARAMS"
hbs-templater compile --params "$MASTER_PARAMS" \
  --input ./templates/k8s_master \
  --output ../k8s_master \
  -l --overwrite
