#!/bin/bash
set -e
IFNAME=127.0.0.1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# remove ubuntu-bionic entry
sed -e '/^.*ubuntu-bionic.*/d' -i /etc/hosts

# Update /etc/hosts about other hosts
cat >> /etc/hosts <<EOF
127.0.0.1  doohee323-desktop
192.168.0.140  master-2
192.168.0.141  worker-1
192.168.0.142  worker-2
192.168.0.143  lb
EOF
