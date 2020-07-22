#!/bin/bash
#set -e
set -x

/bin/cat /vagrant/ubuntu/authorized_keys >> /home/vagrant/.ssh/authorized_keys

echo "====================================================================="
echo " Install docker"
echo "====================================================================="
cd /tmp
curl -fsSL https://get.docker.com -o get-docker.sh
sh /tmp/get-docker.sh

sudo apt-get install conntrack -y