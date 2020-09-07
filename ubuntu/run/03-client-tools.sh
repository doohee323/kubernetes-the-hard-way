#!/bin/bash
set -e
#set -x

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " Installing the Client Tools "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
rm -Rf /home/doohee323/.ssh/id_rsa
ssh-keygen -b 2048 -t rsa -f /home/doohee323/.ssh/id_rsa -q -N ""
cat /home/doohee323/.ssh/id_rsa.pub >> /home/doohee323/.ssh/authorized_keys 
cat /home/doohee323/.ssh/id_rsa.pub > /Volumes/workspace/etc/kubernetes-the-hard-way/ubuntu/authorized_keys

cat > /home/doohee323/.ssh/config <<EOF
Host 192.168.0.*
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


