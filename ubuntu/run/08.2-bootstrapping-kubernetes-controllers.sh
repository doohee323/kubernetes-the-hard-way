#!/bin/bash
set -e
#set -x

echo "====================================================================="
echo " The Kubernetes Frontend Load Balancer"
echo "====================================================================="
#Install HAProxy
sudo apt-get update && sudo apt-get install -y haproxy

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg 
frontend kubernetes
    bind 192.168.0.30:6443
    option tcplog
    mode tcp
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    balance roundrobin
    option tcp-check
    server master-1 192.168.0.139:6443 check fall 3 rise 2
EOF

sudo service haproxy restart

sleep 3

echo "====================================================================="
echo " Validataion"
echo "====================================================================="
curl  https://192.168.0.30:6443/version -k




