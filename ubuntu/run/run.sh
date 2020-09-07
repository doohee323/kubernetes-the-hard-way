#!/bin/bash
set -e
#set -x

cd /Volumes/workspace/etc/kubernetes-the-hard-way/

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 03-client-tools.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/03-client-tools.sh

/bin/bash ubuntu/run/prepare.sh

rm -Rf authorized_keys

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 04-certificate-authority.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/04-certificate-authority.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 05-kubernetes-configuration-files.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/05-kubernetes-configuration-files.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 06-data-encryption-keys.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/06-data-encryption-keys.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 07-bootstrapping-etcd.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/07-bootstrapping-etcd.sh

exit 0


echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 08.1-bootstrapping-kubernetes-controllers.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/08.1-bootstrapping-kubernetes-controllers.sh
ssh -i ../../.vagrant/machines/loadbalancer/virtualbox/private_key doohee323@192.168.0.139 \
        /bin/bash ubuntu/run/08.2-bootstrapping-kubernetes-controllers.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 09.1-bootstrapping-kubernetes-workers.sh - 1st Way - manaual managing"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/09.1-bootstrapping-kubernetes-workers.sh
ssh -i ../../.vagrant/machines/worker-1/virtualbox/private_key doohee323@192.168.0.21 \
        /bin/bash ubuntu/run/09.12-bootstrapping-kubernetes-workers.sh
/usr/local/bin/kubectl get nodes --kubeconfig admin.kubeconfig     

sleep 3
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 10.1-tls-bootstrapping-kubernetes-workers.sh - 2nd Way - worker node by itself"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/10.1-tls-bootstrapping-kubernetes-workers.sh
ssh -i ../../.vagrant/machines/worker-2/virtualbox/private_key doohee323@192.168.0.22 \
        /bin/bash ubuntu/run/10.2-tls-bootstrapping-kubernetes-workers.sh
/usr/local/bin/kubectl get nodes --kubeconfig admin.kubeconfig     

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 11-configuring-kubectl.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/11-configuring-kubectl.sh
  
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 12.1-configure-pod-networking.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../../.vagrant/machines/worker-1/virtualbox/private_key doohee323@192.168.0.21 \
        /bin/bash ubuntu/run/12.1-configure-pod-networking.sh
ssh -i ../../.vagrant/machines/worker-2/virtualbox/private_key doohee323@192.168.0.22 \
        /bin/bash ubuntu/run/12.1-configure-pod-networking.sh
sleep 3 
/bin/bash ubuntu/run/12.2-configure-pod-networking.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 13-kube-apiserver-to-kubelet.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/13-kube-apiserver-to-kubelet.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 14-dns-addon.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/14-dns-addon.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 15-smoke-test.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/15-smoke-test.sh

exit 0

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 16-e2e-tests.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
/bin/bash ubuntu/run/16-e2e-tests.sh




