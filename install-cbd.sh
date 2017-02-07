#!/bin/bash

exec > >(tee "/tmp/${BASH_SOURCE}.log") 2>&1
set -x

: ${CBD_VERSION:="snapshot"}
: ${CBD_DIR:="/var/lib/cloudbreak-deployment"}

custom_data() {
    set -o allexport
    source /tmp/.cbdprofile
    set +o allexport
}

install_cbd() {
    set -x
    curl -Ls s3.amazonaws.com/public-repo-1.hortonworks.com/HDP/cloudbreak/cloudbreak-deployer_${CBD_VERSION}_$(uname)_x86_64.tgz | tar -xz -C /bin cbd
    mkdir $CBD_DIR
    cd $_

    CREDENTIAL_NAME=defaultcredential

    echo export PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com) > Profile
    echo "export AZURE_TENANT_ID=$AZURE_TENANT_ID" >> Profile
    echo "export AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" >> Profile
    echo "export UAA_DEFAULT_USER_EMAIL=$UAA_DEFAULT_USER_EMAIL" >> Profile
    echo "export UAA_DEFAULT_USER_PW=$UAA_DEFAULT_USER_PW" >> Profile
    echo "export CB_SMARTSENSE_CONFIGURE=$CB_SMARTSENSE_CONFIGURE" >> Profile
    echo "export CB_ENABLEDPLATFORMS=AZURE_RM,AZURE" >> Profile

    cbd generate
    cbd pull-parallel
    cbd start-wait
    cbd util smartsense
}

relocate_docker() {
    service docker stop
    rm -rf /var/lib/docker/
    mkdir /mnt/resource/docker
    ln -s /mnt/resource/docker /var/lib/docker
    service docker start
}

disable_dnsmasq() {
    systemctl stop dnsmasq
    systemctl disable dnsmasq.service
}

main() {
    disable_dnsmasq
    apt-get install -y unzip
    custom_data
    #relocate_docker
    install_cbd
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@" || true
