#!/bin/bash

exec > >(tee "/tmp/${BASH_SOURCE}.log") 2>&1
set -x

: ${CBD_VERSION:="azure"}
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

    echo export PUBLIC_IP=$(curl ifconfig.co) > Profile
    echo "export ULU_HWX_CLOUD_PROVIDER='AZURE_RM'" >> Profile
    echo "export ULU_HWX_CLOUD_DEFAULT_REGION='$ULU_HWX_CLOUD_DEFAULT_REGION'" >> Profile
    echo "export ULU_HWX_CLOUD_DEFAULT_SUBNET_ID=$ULU_HWX_CLOUD_DEFAULT_SUBNET_ID" >> Profile
    echo "export ULU_HWX_CLOUD_DEFAULT_CREDENTIAL=$CREDENTIAL_NAME" >> Profile
    echo "export ULU_HWX_CLOUD_AZURE_DEFAULT_VIRTUAL_NETWORK_ID=$ULU_HWX_CLOUD_AZURE_DEFAULT_VIRTUAL_NETWORK_ID" >> Profile
    echo "export ULU_HWX_CLOUD_AZURE_RESOURCE_GROUP=$ULU_HWX_CLOUD_AZURE_RESOURCE_GROUP" >> Profile
    echo "export ULU_HWX_CLOUD_AZURE_SSH_KEY='$ULU_HWX_CLOUD_AZURE_SSH_KEY'" >> Profile
    echo "export AZURE_TENANT_ID=$AZURE_TENANT_ID" >> Profile
    echo "export AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" >> Profile 
    echo "export ULUWATU_CONTAINER_PATH=/hortonworks-cloud-web" >> Profile
    echo "export DOCKER_IMAGE_CLOUDBREAK_WEB=hortonworks/cloud-web" >> Profile
    echo "export DOCKER_TAG_ULUWATU=azure_aws" >> Profile
    echo "export DOCKER_TAG_SULTANS=latest" >> Profile
    echo "export DOCKER_IMAGE_CLOUDBREAK_AUTH=hortonworks/cloud-auth" >> Profile
    echo "export CB_BLUEPRINT_DEFAULTS='EDW-ETL: Apache Hive 1.2.1, Apache Spark 1.6=hdp-etl-edw;Data Science: Apache Spark 1.6, Zeppelin=hdp25-data-science;25EDW-ETL: Apache Hive 1.2.1, Apache Spark 1.6=hdp25-etl-edw;EDW-ETL: Apache Spark 2.0-preview=hdp25-etl-edw-spark2;EDW-Analytics: Apache Hive 2 LLAP, Apache Zeppelin=hdp25-edw-analytics'" >> Profile

    cbd generate
    cbd pull-parallel
    cbd start-wait
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
    custom_data
    #relocate_docker
    install_cbd
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@" || true
