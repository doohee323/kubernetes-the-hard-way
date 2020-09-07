#!/bin/bash
set -e
#set -x

wget https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " Provisioning a CA and Generating TLS Certificates "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "====================================================================="
echo " Certificate Authority"
echo "====================================================================="
rm -Rf ca.*
# Create private key for CA
openssl genrsa -out ca.key 2048
# Comment line starting with RANDFILE in /etc/ssl/openssl.cnf definition to avoid permission issues
sudo sed -i '0,/RANDFILE/{s/RANDFILE/\#&/}' /etc/ssl/openssl.cnf
# Create CSR using the private key
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
# Self sign the csr using its own private key
openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000
ls ca.*

echo "====================================================================="
echo " The Admin Client Certificate"
echo "====================================================================="
rm -Rf admin.*
# Generate private key for admin user
openssl genrsa -out admin.key 2048
# Generate CSR for admin user. Note the OU.
openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr
# Sign certificate for admin user using CA servers private key
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out admin.crt -days 1000
ls admin.*

echo "====================================================================="
echo " The Kubelet Client Certificates"
echo "====================================================================="
rm -Rf kube-controller-manager.*
openssl genrsa -out kube-controller-manager.key 2048
openssl req -new -key kube-controller-manager.key -subj "/CN=system:kube-controller-manager" -out kube-controller-manager.csr
openssl x509 -req -in kube-controller-manager.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kube-controller-manager.crt -days 1000
ls kube-controller-manager.*

echo "====================================================================="
echo " The Kube Proxy Client Certificate"
echo "====================================================================="
rm -Rf kube-proxy.*
openssl genrsa -out kube-proxy.key 2048
openssl req -new -key kube-proxy.key -subj "/CN=system:kube-proxy" -out kube-proxy.csr
openssl x509 -req -in kube-proxy.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-proxy.crt -days 1000
ls kube-proxy.*

echo "====================================================================="
echo " The Scheduler Client Certificate"
echo "====================================================================="
rm -Rf kube-scheduler.*
openssl genrsa -out kube-scheduler.key 2048
openssl req -new -key kube-scheduler.key -subj "/CN=system:kube-scheduler" -out kube-scheduler.csr
openssl x509 -req -in kube-scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-scheduler.crt -days 1000
ls kube-scheduler.*

echo "====================================================================="
echo " The Kubernetes API Server Certificate"
echo "====================================================================="
cat > openssl.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = 192.168.0.139
IP.3 = 192.168.0.139
IP.4 = 192.168.0.139
IP.5 = 127.0.0.1
EOF
rm -Rf kube-apiserver.*
openssl genrsa -out kube-apiserver.key 2048
openssl req -new -key kube-apiserver.key -subj "/CN=kube-apiserver" -out kube-apiserver.csr -config openssl.cnf
openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-apiserver.crt -extensions v3_req -extfile openssl.cnf -days 1000
ls kube-apiserver.*

echo "====================================================================="
echo " The ETCD Server Certificate"
echo "====================================================================="
cat > openssl-etcd.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = 192.168.0.139
IP.2 = 192.168.0.139
IP.3 = 127.0.0.1
EOF
rm -Rf etcd-server.*
openssl genrsa -out etcd-server.key 2048
openssl req -new -key etcd-server.key -subj "/CN=etcd-server" -out etcd-server.csr -config openssl-etcd.cnf
openssl x509 -req -in etcd-server.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out etcd-server.crt -extensions v3_req -extfile openssl-etcd.cnf -days 1000
ls etcd-server.*

echo "====================================================================="
echo " The Service Account Key Pair"
echo "====================================================================="
rm -Rf service-account.*
openssl genrsa -out service-account.key 2048
openssl req -new -key service-account.key -subj "/CN=service-accounts" -out service-account.csr
openssl x509 -req -in service-account.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out service-account.crt -days 1000
ls service-account.*

echo "====================================================================="
echo " Distribute the Certificates"
echo "====================================================================="
for instance in master-1; do
  echo $instance
  scp ca.crt ca.key kube-apiserver.key kube-apiserver.crt \
    service-account.key service-account.crt \
    etcd-server.key etcd-server.crt \
    ${instance}:~/
done

for instance in worker-2; do
  echo $instance
  scp ca.crt \
    ${instance}:~/
done


