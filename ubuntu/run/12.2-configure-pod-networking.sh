#!/bin/bash
set -e
#set -x

echo "====================================================================="
echo " Verification"
echo "====================================================================="
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

sleep 5

kubectl get pods -n kube-system -o wide



