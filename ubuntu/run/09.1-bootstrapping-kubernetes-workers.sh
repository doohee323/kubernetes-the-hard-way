#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " Bootstrapping the Kubernetes Worker Nodes -> 1st Way "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

echo "====================================================================="
echo " Provisioning Kubelet Client Certificates"
echo "====================================================================="
rm -Rf worker-1.*
cat > openssl-worker-1.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = worker-1
IP.1 = 127.0.0.1
EOF

openssl genrsa -out worker-1.key 2048
openssl req -new -key worker-1.key -subj "/CN=system:node:worker-1/O=system:nodes" -out worker-1.csr -config openssl-worker-1.cnf
openssl x509 -req -in worker-1.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out worker-1.crt -extensions v3_req -extfile openssl-worker-1.cnf -days 1000
ls worker-1.*

echo "====================================================================="
echo " The kubelet Kubernetes Configuration File"
echo "====================================================================="
LOADBALANCER_ADDRESS=127.0.0.1

rm -Rf worker-1.kubeconfig
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://${LOADBALANCER_ADDRESS}:6443 \
    --kubeconfig=worker-1.kubeconfig

kubectl config set-credentials system:node:worker-1 \
--client-certificate=worker-1.crt \
--client-key=worker-1.key \
--embed-certs=true \
--kubeconfig=worker-1.kubeconfig

kubectl config set-context default \
--cluster=kubernetes-the-hard-way \
--user=system:node:worker-1 \
--kubeconfig=worker-1.kubeconfig

kubectl config use-context default --kubeconfig=worker-1.kubeconfig

ls worker-1.kubeconfig


scp ca.crt worker-1.crt worker-1.key worker-1.kubeconfig worker-1:~/

set +e
echo "====================================================================="
echo " Validation after 09.1-"
echo "====================================================================="

kubectl get nodes --kubeconfig admin.kubeconfig


