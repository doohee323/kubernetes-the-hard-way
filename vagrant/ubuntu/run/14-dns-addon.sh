#!/bin/bash
set +e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " Deploying the DNS Cluster Add-on "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

kubectl apply -f https://raw.githubusercontent.com/mmumshad/kubernetes-the-hard-way/master/deployments/coredns.yaml

kubectl get pods -l k8s-app=kube-dns -n kube-system

echo "====================================================================="
echo " Verification"
echo "====================================================================="

kubectl get csr
CSR=`kubectl get csr | grep Pending | awk '{print $1}'`

kubectl certificate approve $CSR

kubectl get csr

WEAVE_ID=`kubectl get pods -n kube-system | grep 'weave-net' | head -n 1 | awk '{print $1}'`
 
kubectl logs $WEAVE_ID weave -n kube-system

kubectl run --generator=run-pod/v1  busybox --image=busybox:1.28 --command -- sleep 3600

echo sleep 60
sleep 60

kubectl get pods -l run=busybox

kubectl exec -ti busybox -- nslookup kubernetes

