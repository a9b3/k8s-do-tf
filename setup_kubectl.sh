parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

echo ""

if [ $CLEAN_SLATE ]; then
  rm -rf ./certs/admin-key.pem
  rm -rf ./certs/admin.csr
  rm -rf ./certs/admin.pem
fi

if [ -e ./certs/admin-key.pem ]; then
  echo "admin-key already exists using existing key ..."
else
  echo "Creating cluster admin keypair ..."
  openssl genrsa -out ./certs/admin-key.pem 2048

  openssl req -new -key ./certs/admin-key.pem \
    -out ./certs/admin.csr \
    -subj "/CN=kube-admin"

  openssl x509 -req -in ./certs/admin.csr \
    -CA ./certs/ca.pem \
    -CAkey ./certs/ca-key.pem \
    -CAcreateserial \
    -out ./certs/admin.pem \
    -days 365
fi

echo ""

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
