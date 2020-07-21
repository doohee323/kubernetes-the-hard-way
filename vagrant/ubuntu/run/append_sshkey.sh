#!/bin/bash
#set -e
set -x

/bin/cat /vagrant/ubuntu/authorized_keys >> /home/vagrant/.ssh/authorized_keys
