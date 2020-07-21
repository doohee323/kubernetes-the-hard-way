#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 01.setting ssh among nodes "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key \
    vagrant@192.168.5.11 /bin/bash /vagrant/ubuntu/ubuntu/make_sshkey.sh

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
        /bin/bash /vagrant/ubuntu/ubuntu/append_sshkey.sh
done

rm -Rf authorized_keys

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 02.tls_certificates.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/vagrant/02.tls_certificates.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 03.k8s_auth.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/vagrant/03.k8s_auth.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 04.encryt_key.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/vagrant/04.encryt_key.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 05.etcd_server.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/vagrant/05.etcd_server.sh
sleep 3
ssh -i ../.vagrant/machines/master-2/virtualbox/private_key vagrant@192.168.5.12 \
        /bin/bash /vagrant/ubuntu/vagrant/05.etcd_server.sh

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " 06-1.control_plane.sh / 06-2.loadbalancer.sh "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
ssh -i ../.vagrant/machines/master-1/virtualbox/private_key vagrant@192.168.5.11 \
        /bin/bash /vagrant/ubuntu/vagrant/06-1.control_plane.sh
ssh -i ../.vagrant/machines/master-2/virtualbox/private_key vagrant@192.168.5.12 \
        /bin/bash /vagrant/ubuntu/vagrant/06-1.control_plane.sh
sleep 3
ssh -i ../.vagrant/machines/loadbalancer/virtualbox/private_key vagrant@192.168.5.30 \
        /bin/bash /vagrant/ubuntu/vagrant/06-2.loadbalancer.sh
