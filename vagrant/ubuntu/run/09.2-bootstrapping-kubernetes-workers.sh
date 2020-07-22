#!/bin/bash
set -e
#set -x

echo "====================================================================="
echo " Configure the Kubelet on Worker"
echo "====================================================================="

wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kubelet

sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

sudo chmod +x kubectl kube-proxy kubelet
sudo mv kubectl kube-proxy kubelet /usr/local/bin/

if [[ -f ${HOSTNAME}.key ]]; then
    sudo mv ${HOSTNAME}.key ${HOSTNAME}.crt /var/lib/kubelet/
    sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
fi
if [[ -f ca.crt ]]; then
    sudo mv ca.crt /var/lib/kubernetes/
fi

sudo rm -Rf /var/lib/kubelet/kubelet-config.yaml
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.96.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
EOF

#sudo rm -Rf /etc/systemd/system/kubelet.service
# cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
# [Unit]
# Description=Kubernetes Kubelet
# Documentation=https://github.com/kubernetes/kubernetes
# After=docker.service
# Requires=docker.service

# [Service]
# ExecStart=/usr/local/bin/kubelet \\
#   --config=/var/lib/kubelet/kubelet-config.yaml \\
#   --image-pull-progress-deadline=2m \\
#   --kubeconfig=/var/lib/kubelet/kubeconfig \\
#   --tls-cert-file=/var/lib/kubelet/HOSTNAME.crt \\
#   --tls-private-key-file=/var/lib/kubelet/HOSTNAME.key \\
#   --network-plugin=cni \\
#   --register-node=true \\
#   --v=2
# Restart=on-failure
# RestartSec=5

# [Install]
# WantedBy=multi-user.target
# EOF

echo "====================================================================="
echo " Step 4 Configure Kubelet to TLS Bootstrap"
echo "====================================================================="
sudo rm -Rf /var/lib/kubelet/bootstrap-kubeconfig
cat <<EOF | sudo tee /var/lib/kubelet/bootstrap-kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/lib/kubernetes/ca.crt
    server: https://192.168.5.30:6443
  name: bootstrap
contexts:
- context:
    cluster: bootstrap
    user: kubelet-bootstrap
  name: bootstrap
current-context: bootstrap
kind: Config
preferences: {}
users:
- name: kubelet-bootstrap
  user:
    token: 07401b.f395accd246ae52d
EOF

sudo rm -Rf /etc/systemd/system/kubelet.service
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --bootstrap-kubeconfig="/var/lib/kubelet/bootstrap-kubeconfig" \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --cert-dir=/var/lib/kubelet/pki/ \\
  --rotate-certificates=true \\
  --rotate-server-certificates=true \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo sed -i s/HOSTNAME/${HOSTNAME}/g /etc/systemd/system/kubelet.service

echo "====================================================================="
echo " Configure the Kubernetes Proxy"
echo "====================================================================="
if [[ -f kube-proxy.kubeconfig ]]; then
    sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
fi

sudo rm -Rf /var/lib/kube-proxy/kube-proxy-config.yaml
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "192.168.5.0/24"
EOF

sudo rm -Rf /etc/systemd/system/kube-proxy.service
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable kubelet kube-proxy
sudo systemctl start kubelet kube-proxy

