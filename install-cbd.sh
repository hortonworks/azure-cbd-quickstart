#!/bin/bash

exec > >(tee "/var/log/${BASH_SOURCE}.log") 2>&1
set -x

: ${CBD_VERSION:="snapshot"}
: ${CBD_DIR:="/var/lib/cloudbreak-deployment"}

custom_data() {
    set -o allexport
    source /tmp/.cbdprofile
    set +o allexport
    rm /tmp/.cbdprofile
}

download_cbd() {
    set -x
    curl -Ls s3.amazonaws.com/public-repo-1.hortonworks.com/HDP/cloudbreak/cloudbreak-deployer_${CBD_VERSION}_$(uname)_x86_64.tgz | tar -xz -C /bin cbd
    mkdir $CBD_DIR
    cd $_
    whoami
}

install_cbd() {

    CREDENTIAL_NAME=defaultcredential

    echo "export PUBLIC_IP=$PUBLIC_IP" > Profile
    echo "export CB_TRAEFIK_HOST_ADDRESS=$CB_TRAEFIK_HOST_ADDRESS" >> Profile
    echo "export AZURE_TENANT_ID=$AZURE_TENANT_ID" >> Profile
    echo "export AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" >> Profile
    echo "export UAA_DEFAULT_USER_EMAIL=$UAA_DEFAULT_USER_EMAIL" >> Profile
    echo "export UAA_DEFAULT_USER_PW=$UAA_DEFAULT_USER_PW" >> Profile
    echo "export UAA_DEFAULT_SECRET=$UAA_DEFAULT_SECRET" >> Profile
    echo "export CB_SMARTSENSE_CONFIGURE=$CB_SMARTSENSE_CONFIGURE" >> Profile
    echo "export CB_ENABLEDPLATFORMS=AZURE" >> Profile
    echo "export ULU_DEFAULT_SSH_KEY='$ULU_DEFAULT_SSH_KEY'" >> Profile
    echo "export CB_BLUEPRINT_DEFAULTS='$CB_BLUEPRINT_DEFAULTS'" >> Profile
    echo "export CB_INSTANCE_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')" >> Profile

    cbd generate
    cbd pull-parallel
    cbd start-wait
    cbd util smartsense
    whoami
}

set_perm() {
    usermod -aG docker ${OS_USER}
    chown -R $OS_USER:$OS_USER $CBD_DIR
    chown -R $OS_USER:$OS_USER /var/lib/cloudbreak/
    whoami
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
    custom_data
    #relocate_docker
    download_cbd
    set_perm
    export -f install_cbd
    su $OS_USER -c "install_cbd"
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@" || true
