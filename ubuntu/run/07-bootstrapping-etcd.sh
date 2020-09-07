#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " Bootstrapping the etcd Cluster "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

wget -q --show-progress --https-only --timestamping \
  "https://github.com/coreos/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz"

tar -xvf etcd-v3.3.9-linux-amd64.tar.gz
sudo mv etcd-v3.3.9-linux-amd64/etcd* /usr/local/bin/

sudo mkdir -p /etc/etcd /var/lib/etcd
sudo cp ca.crt etcd-server.key etcd-server.crt /etc/etcd/

#INTERNAL_IP=$(ip addr show eno1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
INTERNAL_IP=127.0.0.1
ETCD_NAME=$(hostname -s)
echo $INTERNAL_IP
echo $ETCD_NAME

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ETCD_NAME \\
  --cert-file=/etc/etcd/etcd-server.crt \\
  --key-file=/etc/etcd/etcd-server.key \\
  --peer-cert-file=/etc/etcd/etcd-server.crt \\
  --peer-key-file=/etc/etcd/etcd-server.key \\
  --trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://INTERNAL_IP:2380 \\
  --listen-peer-urls https://INTERNAL_IP:2380 \\
  --listen-client-urls https://INTERNAL_IP:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://INTERNAL_IP:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ETCD_NAME=https://192.168.0.139:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "====================================================================="
echo " Configure the etcd Server"
echo "====================================================================="

sudo sed -i "s/ETCD_NAME/${ETCD_NAME}/g" /etc/systemd/system/etcd.service
sudo sed -i "s/INTERNAL_IP/${INTERNAL_IP}/g" /etc/systemd/system/etcd.service

sudo systemctl daemon-reload
sudo systemctl enable etcd
#sudo systemctl stop etcd
sudo systemctl start etcd
#sudo systemctl status etcd

echo "====================================================================="
echo " Validataion"
echo "====================================================================="
set +e
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/etcd-server.crt \
  --key=/etc/etcd/etcd-server.key

exit 0