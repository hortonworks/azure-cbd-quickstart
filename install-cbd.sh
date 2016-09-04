#!/bin/bash

exec > >(tee "/tmp/${BASH_SOURCE}.log") 2>&1
set -x

: ${CBD_VERSION:="1.3.0"}
: ${CBD_DIR:="/var/lib/cloudbreak-deployment"}
: ${WAIT_FOR_CB_RETRY:=50}

check_custom_data() {
  CDATA_FILE=/var/lib/waagent/CustomData
  if [[ -e $CDATA_FILE ]]; then
    # if it hash shebang, run it
    base64 -d $CDATA_FILE > ${CDATA_FILE}.txt
    if head -1 ${CDATA_FILE}.txt|grep -qe '^#!' ;then
        source ${CDATA_FILE}.txt
    fi

    # if it has CBD specific env settings
    if grep -q CBD_ ${CDATA_FILE}.txt; then
        eval "$(grep CBD_ ${CDATA_FILE}.txt)"
    fi
  fi

}

install_cbd() {
    set +x
    curl -Ls s3.amazonaws.com/public-repo-1.hortonworks.com/HDP/cloudbreak/cloudbreak-deployer_${CBD_VERSION}_$(uname)_x86_64.tgz | tar -xz -C /bin cbd
    mkdir $CBD_DIR
    cd $_

    CREDENTIAL_NAME=defaultcredential

    echo export PUBLIC_IP=$(curl ifconfig.co) > Profile
    echo "export AZURE_RESOURCE_GROUP_ID=$AZURE_RESOURCE_GROUP_ID" >> Profile
    echo "export AZURE_VIRTUAL_NETWORK_ID=$AZURE_VIRTUAL_NETWORK_ID" >> Profile
    echo "export AZURE_SUBNET_ID=$AZURE_SUBNET_ID" >> Profile
    echo "export AZURE_DEFAULT_CREDENTIAL=$CREDENTIAL_NAME" >> Profile

    cbd generate
    cbd pull-parallel
    cbd start-wait
    echo "credential create --AZURE --name $CREDENTIAL_NAME --sshKeyString '$SSH_KEY_STRING' --subscriptionId $AZURE_SUBSCRIPTION_ID --tenantId $AZURE_TENANT_ID --appId $AZURE_APP_ID --password $AZURE_PASSWORD" >> create-default-azure-role.sh
    cbd util cloudbreak-shell-quiet < create-default-azure-role.sh
}

execute_cb_shell_script() {
    if [[ -n "$SHELL_SCRIPT" ]]; then
        cd $CBD_DIR
        echo "$(base64 -d <(echo "$SHELL_SCRIPT"))" | cbd util cloudbreak-shell-quiet
    fi
}

relocate_docker() {
    service docker stop
    rm -rf /var/lib/docker/
    mkdir /mnt/resource/docker
    ln -s /mnt/resource/docker /var/lib/docker
    service docker start
}

main() {
    apt-get install -y unzip
    check_custom_data
    #relocate_docker
    install_cbd
    execute_cb_shell_script
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@" || true
