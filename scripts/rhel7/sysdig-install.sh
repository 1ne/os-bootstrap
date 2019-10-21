#!/bin/bash

##### Installing Sysdig Monitoring Tools #####
sudo rpm --import https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public
sudo curl -s -o /etc/yum.repos.d/draios.repo http://download.draios.com/stable/rpm/draios.repo

sudo yum -y install kernel-devel-$(uname -r)
sudo yum -y install sysdig
sudo yum update -y