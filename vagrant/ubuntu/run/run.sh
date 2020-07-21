#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 04-certificate-authority.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key \
    vagrant@192.168.5.11 /bin/bash /vagrant/run/04-certificate-authority.sh

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
    ssh -i ../.vagrant/machines/${instance}/virtualbox/private_key vagrant@${ip} \
        /bin/bash /vagrant/ubuntu/run/append_sshkey.sh
done

rm -Rf authorized_keys

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 05-kubernetes-configuration-files.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/05-kubernetes-configuration-files.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 06-data-encryption-keys.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/06-data-encryption-keys.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 07-bootstrapping-etcd.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/07-bootstrapping-etcd.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 08-bootstrapping-kubernetes-controllers.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/08-bootstrapping-kubernetes-controllers.sh
sleep 3
ssh -i ../.vagrant/machines/master-2/virtualbox/private_key vagrant@192.168.5.12 \
        /bin/bash /vagrant/ubuntu/run/08-bootstrapping-kubernetes-controllers.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 09.1-bootstrapping-kubernetes-workers.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/run/09.1-bootstrapping-kubernetes-workers.sh
ssh -i ../.vagrant/machines/master-2/virtualbox/private_key vagrant@192.168.5.12 \
        /bin/bash /vagrant/ubuntu/run/09.1-bootstrapping-kubernetes-workers.sh
sleep 3
ssh -i ../.vagrant/machines/loadbalancer/virtualbox/private_key vagrant@192.168.5.30 \
        /bin/bash /vagrant/ubuntu/run/09.2-bootstrapping-kubernetes-workers.sh

