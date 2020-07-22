#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 03-client-tools.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key \
    vagrant@192.168.5.11 /bin/bash /vagrant/ubuntu/run/03-client-tools.sh

echo "appending master's .ssh/id_rsa.pub to other nodes' authorized_keys!"
for e in master_2 worker_1 worker_2 loadbalancer; do
    if [[ ${e} == 'master_2' ]]; then
        ip=192.168.5.12
        instance='master-2'
    elif [[ ${e} == 'worker_1' ]]; then
        ip=192.168.5.21
        instance='worker-1'
    elif [[ ${e} == 'worker_2' ]]; then
        ip=192.168.5.22
        instance='worker-2'
    elif [[ ${e} == 'loadbalancer' ]]; then
        ip=192.168.5.30
        instance='loadbalancer'
    fi
    ssh -o IdentitiesOnly=yes -i ../../.vagrant/machines/${instance}/virtualbox/private_key vagrant@${ip} \
        /bin/bash /vagrant/ubuntu/run/prepare.sh
done

rm -Rf authorized_keys

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 04-certificate-authority.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/04-certificate-authority.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 05-kubernetes-configuration-files.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/05-kubernetes-configuration-files.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 06-data-encryption-keys.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/06-data-encryption-keys.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 07-bootstrapping-etcd.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/07-bootstrapping-etcd.sh
sleep 3
ssh -i ../../.vagrant/machines/master-2/virtualbox/private_key vagrant@192.168.5.12 \
        /bin/bash /vagrant/ubuntu/run/07-bootstrapping-etcd.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 08.1-bootstrapping-kubernetes-controllers.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/08.1-bootstrapping-kubernetes-controllers.sh
ssh -i ../../.vagrant/machines/master-2/virtualbox/private_key vagrant@192.168.5.12 \
        /bin/bash /vagrant/ubuntu/run/08.1-bootstrapping-kubernetes-controllers.sh
sleep 3
ssh -i ../../.vagrant/machines/loadbalancer/virtualbox/private_key vagrant@192.168.5.30 \
        /bin/bash /vagrant/ubuntu/run/08.2-bootstrapping-kubernetes-controllers.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 09.1-bootstrapping-kubernetes-workers.sh - 1st Way - manaual managing"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/09.1-bootstrapping-kubernetes-workers.sh
ssh -i ../../.vagrant/machines/worker-1/virtualbox/private_key vagrant@192.168.5.21 \
        /bin/bash /vagrant/ubuntu/run/09.12-bootstrapping-kubernetes-workers.sh
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
		/usr/local/bin/kubectl get nodes --kubeconfig admin.kubeconfig     

sleep 3
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 10.1-tls-bootstrapping-kubernetes-workers.sh - 2nd Way - worker node by itself"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/10.1-tls-bootstrapping-kubernetes-workers.sh
ssh -i ../../.vagrant/machines/worker-2/virtualbox/private_key vagrant@192.168.5.22 \
        /bin/bash /vagrant/ubuntu/run/10.2-tls-bootstrapping-kubernetes-workers.sh
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
		/usr/local/bin/kubectl get nodes --kubeconfig admin.kubeconfig     

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 11-configuring-kubectl.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/11-configuring-kubectl.sh
  
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 12.1-configure-pod-networking.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/worker-1/virtualbox/private_key vagrant@192.168.5.21 \
        /bin/bash /vagrant/ubuntu/run/12.1-configure-pod-networking.sh
ssh -i ../../.vagrant/machines/worker-2/virtualbox/private_key vagrant@192.168.5.22 \
        /bin/bash /vagrant/ubuntu/run/12.1-configure-pod-networking.sh
sleep 3 
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/12.2-configure-pod-networking.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 13-kube-apiserver-to-kubelet.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/13-kube-apiserver-to-kubelet.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 14-dns-addon.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/14-dns-addon.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 15-smoke-test.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/15-smoke-test.sh

exit 0

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 16-e2e-tests.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/16-e2e-tests.sh




