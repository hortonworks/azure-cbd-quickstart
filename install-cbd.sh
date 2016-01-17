#!/bin/bash

exec > >(tee "/tmp/${BASH_SOURCE}.log") 2>&1
set -x

yum install -y unzip
pwd
curl -Ls public-repo-1.hortonworks.com/HDP/cloudbreak/cloudbreak-deployer_${CBD_VERSION:=1.1.0}_$(uname)_x86_64.tgz | tar -xz -C /bin cbd

mkdir /var/lib/cloudbreak-deployment
cd $_
echo export PUBLIC_IP=$(curl ipecho.net/plain) > Profile
cbd init
