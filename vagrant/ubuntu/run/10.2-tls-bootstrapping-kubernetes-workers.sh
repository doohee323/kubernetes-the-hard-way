#!/bin/bash
set -e
#set -x

echo "====================================================================="
echo " Step 9 Approve Server CSR"
echo "====================================================================="
kubectl get csr
CSR=`kubectl get csr | grep Pending | awk '{print $1}'`

kubectl certificate approve $CSR

kubectl get csr

kubectl get nodes --kubeconfig admin.kubeconfig




