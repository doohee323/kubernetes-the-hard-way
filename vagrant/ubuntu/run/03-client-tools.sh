#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " Installing the Client Tools "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
rm -Rf /home/vagrant/.ssh/id_rsa
ssh-keygen -b 2048 -t rsa -f /home/vagrant/.ssh/id_rsa -q -N ""
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys 
cat /home/vagrant/.ssh/id_rsa.pub > /vagrant/ubuntu/authorized_keys

cat > /home/vagrant/.ssh/config <<EOF
Host 192.168.5.*
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
Host master-*
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
Host worker-*
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
Host loadbalancer
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
EOF


