parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

MASTER_IP=$(terraform output | grep master_ip | cut -d\  -f3)
echo $MASTER_IP
if [[ -z "${MASTER_IP// }" ]]; then
  echo "MASTER_IP cannot be found from terraform output make sure to run this
  script after terraform apply"
  exit 1
fi

echo ""

MASTER_URL=http://$MASTER_IP:8080
CA_CERT=$(pwd)/certs/ca.pem
ADMIN_KEY=$(pwd)/certs/admin-key.pem
ADMIN_CERT=$(pwd)/certs/admin.pem

echo "MASTER_URL=$MASTER_URL"

until curl $MASTER_URL >/dev/null 2>&1; do
  echo waiting for $MASTER_URL to be ready
  sleep 5
done

kubectl config set-cluster default-cluster \
  --server=$MASTER_URL \
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
