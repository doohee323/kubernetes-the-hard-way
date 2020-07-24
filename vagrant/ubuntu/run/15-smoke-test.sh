#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " Smoke Test "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

echo "====================================================================="
echo " Data Encryption"
echo "====================================================================="

kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"

sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/etcd-server.crt \
  --key=/etc/etcd/etcd-server.key\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C

kubectl delete secret kubernetes-the-hard-way

echo "====================================================================="
echo " Deployments"
echo "====================================================================="

kubectl create deployment nginx --image=nginx

sleep 10

kubectl get pods -l app=nginx

echo "====================================================================="
echo " Services"
echo "====================================================================="

kubectl expose deploy nginx --type=NodePort --port 80

sleep 10

PORT_NUMBER=$(kubectl get svc -l app=nginx -o jsonpath="{.items[0].spec.ports[0].nodePort}")

curl http://worker-1:$PORT_NUMBER
curl http://worker-2:$PORT_NUMBER

echo "====================================================================="
echo " Logs"
echo "====================================================================="

POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
kubectl logs $POD_NAME

echo "====================================================================="
echo " Exec"
echo "====================================================================="
kubectl exec -ti $POD_NAME -- nginx -v

kubectl get csr
echo kubectl certificate approve $CSR
