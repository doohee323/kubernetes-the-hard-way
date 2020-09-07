#!/bin/bash

########################################################################
# install kubelet kubeadm kubectl kubernetes-cni
########################################################################
sudo apt install apt-transport-https curl -y
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install kubelet kubeadm kubectl kubernetes-cni -y

sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
sudo sysctl -w net.ipv4.ip_forward=1
sudo swapoff -a

chmod 777 /var/run/docker.sock
service docker restart

sudo kubeadm init --pod-network-cidr=10.244.0.0/16

########################################################################
# set .kube/config with doohee323
########################################################################
mkdir -p $HOME/.kube
sudo cp -Rf /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

########################################################################
# add Pod Network 
########################################################################
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sleep 60
kubectl get nodes

########################################################################
# add slave 
########################################################################
INTERNAL_IP=$(ip addr show eno1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
INTERNAL_IP=192.168.0.139
#sudo kubeadm join $INTERNAL_IP:6443 --token 95bt0c.dqi8yv7xzhbqgwcp --discovery-token-ca-cert-hash sha256:b2c7c12685340f8782013b2fe0c1521c74f02994b9f15a068f13a38a39c114c0
#kubectl get nodes

########################################################################
# install dashboard 
########################################################################
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
kubectl get pods --all-namespaces
sleep 60
#kubectl -n kube-system get service kubernetes-dashboard
kubectl proxy --accept-hosts='^*' &

########################################################################
# create auth
########################################################################
cat <<EOF | tee dashboard-adminuser.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f dashboard-adminuser.yaml

cat <<EOF | tee dashboard-clusterrole.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
rules:
  # Allow Metrics Scraper to get metrics from the Metrics server
  - apiGroups: ["metrics.k8s.io"]
    resources: ["pods", "nodes"]
    verbs: ["get", "list", "watch"]

  # Other resources
  - apiGroups: [""]
    resources: ["nodes", "namespaces", "pods", "serviceaccounts", "services", "configmaps", "endpoints", "persistentvolumeclaims", "replicationcontrollers", "replicationcontrollers/scale", "persistentvolumeclaims", "persistentvolumes", "bindings", "events", "limitranges", "namespaces/status", "pods/log", "pods/status", "replicationcontrollers/status", "resourcequotas", "resourcequotas/status"]
    verbs: ["get", "list", "watch"]
  
  - apiGroups: ["apps"]
    resources: ["daemonsets", "deployments", "deployments/scale", "replicasets", "replicasets/scale", "statefulsets"]
    verbs: ["get", "list", "watch"]

  - apiGroups: ["autoscaling"]
    resources: ["horizontalpodautoscalers"]
    verbs: ["get", "list", "watch"]

  - apiGroups: ["batch"]
    resources: ["cronjobs", "jobs"]
    verbs: ["get", "list", "watch"]

  - apiGroups: ["extensions"]
    resources: ["daemonsets", "deployments", "deployments/scale", "networkpolicies", "replicasets", "replicasets/scale", "replicationcontrollers/scale"]
    verbs: ["get", "list", "watch"]

  - apiGroups: ["networking.k8s.io"]
    resources: ["ingresses", "networkpolicies"]
    verbs: ["get", "list", "watch"]

  - apiGroups: ["policy"]
    resources: ["poddisruptionbudgets"]
    verbs: ["get", "list", "watch"]

  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses", "volumeattachments"]
    verbs: ["get", "list", "watch"]

  - apiGroups: ["rbac.authorization.k8s.io"]
    resources: ["clusterrolebindings", "clusterroles", "roles", "rolebindings", ]
    verbs: ["get", "list", "watch"]
EOF
kubectl apply -f dashboard-clusterrole.yaml

echo "get token"
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

curl http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

########################################################################
# install apache
########################################################################
sudo apt install apache2 -y
sudo a2enmod ssl
sudo a2enmod proxy
sudo a2enmod proxy_html
sudo a2enmod proxy_http
sudo a2enmod rewrite

#vi /etc/apache2/apache2.conf
#<Directory /var/www/html>
#AllowOverride All
#</Directory>

mkdir /etc/apache2/certificate
cd /etc/apache2/certificate
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out apache-certificate.crt -keyout apache.key

cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf_bak
#mv /etc/apache2/sites-available/000-default.conf_bak /etc/apache2/sites-available/000-default.conf

cat <<EOF | sudo tee /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
  ServerName dooheehong323

  SSLEngine off
  ProxyPreserveHost On
  ProxyRequests Off

  RewriteEngine On
  RewriteCond %{HTTPS} !=on
  RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R=301,L]

  <Directory />
    AllowOverride All
    Options All
    Require all granted
  </Directory>
</VirtualHost>

<VirtualHost *:443>
  ServerName dooheehong323

  SSLEngine on
  
  SSLCertificateKeyFile /etc/apache2/certificate/apache.key
  SSLCertificateFile /etc/apache2/certificate/apache-certificate.crt

  ProxyPreserveHost On
  ProxyRequests Off

  ProxyPass / http://127.0.0.1:8001/
  ProxyPassReverse / http://127.0.0.1:8001/

  <Directory />
    AllowOverride All
    Options All
    Require all granted
  </Directory>
</VirtualHost>

EOF

sudo service apache2 restart
#sudo service apache2 status

curl http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.
curl https://dooheehong323/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login

exit 0

grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.crt
grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.key

openssl pkcs12 -export -clcerts -inkey kubecfg.key -in kubecfg.crt -out kubecfg.p12 -name "kubernetes-admin"
ll kubecfg.p12 

####################################
# install helm
####################################
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm


helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm install my-release kubernetes-dashboard/kubernetes-dashboard


cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system ServiceAccount
EOF

cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1 
kind: ClusterRoleBinding 
metadata: 
  name: admin-user 
roleRef: 
  apiGroup: rbac.authorization.k8s.io 
  kind: ClusterRole 
  name: cluster-admin 
subjects: 
- kind: ServiceAccount 
  name: admin-user 
  namespace: kube-system 
EOF

kubectl -n kube-system delete ServiceAccount admin-user
kubectl -n kube-system delete ClusterRoleBinding admin-user
kubectl -n kube-system delete ClusterRole cluster-admin



kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') 









** uncertified certi issue
https://support.securly.com/hc/en-us/articles/206058318-How-to-install-the-Securly-SSL-certificate-on-Mac-OSX-

####################################
# remove all k8s 1
####################################
sudo systemctl stop kube-apiserver kube-controller-manager kube-scheduler
sudo systemctl disable kube-apiserver kube-controller-manager kube-scheduler

sudo systemctl stop kubelet kube-proxy
sudo systemctl disable kubelet kube-proxy

sudo rm -Rf /usr/local/bin/kube*

sudo systemctl stop etcd
sudo systemctl disable etcd
sudo rm -Rf /usr/local/bin/etcd*

sudo service haproxy stop
sudo systemctl disable haproxy
rm -Rf /var/lib/etcd/*
sudo swapoff -a

####################################
# remove all k8s 2
####################################
kubeadm reset
sudo rm -Rf /etc/cni/net.d
sudo apt install ipvsadm
sudo ipvsadm --clear
rm $HOME/.kube/config

sudo apt purge kubelet kubeadm kubectl kubernetes-cni -y
sudo rm -Rf /usr/local/bin/etcd*

sudo swapoff -a
sudo rm -Rf /etc/kubernetes
sudo rm -Rf /var/lib/etcd
ps -ef | grep kube | awk '{print $2}' | xargs kill -9


####################################
# kubectl
####################################
#wget https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl
#chmod +x kubectl
#sudo mv kubectl /usr/local/bin/
#kubectl version --client

