parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

MASTER_IP=http://$1:8080
CA_CERT=$(pwd)/certs/ca.pem
ADMIN_KEY=$(pwd)/certs/admin-key.pem
ADMIN_CERT=$(pwd)/certs/admin.pem

echo "MASTER_IP=$MASTER_IP"

kubectl config set-cluster default-cluster \
  --server=$MASTER_IP \
  --certificate-authority=$CA_CERT \
  --client-key=$ADMIN_KEY \
  --client-certificate=$ADMIN_CERT
kubectl config set-credentials default-admin \
  --certificate-authority=$CA_CERT \
  --client-key=$ADMIN_KEY \
  --client-certificate=$ADMIN_CERT
kubectl config set-context default-system \
  --cluster=default-cluster \
  --user=default-admin
kubectl config use-context default-system
