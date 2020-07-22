#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " Configuring kubectl for Remote Access "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

echo "====================================================================="
echo " The Admin Kubernetes Configuration File"
echo "====================================================================="
KUBERNETES_LB_ADDRESS=192.168.5.30

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://${KUBERNETES_LB_ADDRESS}:6443

kubectl config set-credentials admin \
  --client-certificate=admin.crt \
  --client-key=admin.key

kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin

kubectl config use-context kubernetes-the-hard-way

kubectl config view
cat .kube/config

kubectl get componentstatuses

kubectl get nodes

