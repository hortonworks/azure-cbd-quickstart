#!/bin/bash

exec > >(tee "/tmp/${BASH_SOURCE}.log") 2>&1
set -x

${CBD_DIR:="/var/lib/cloudbreak-deployment"}
${CBD_VERSION:="1.1.0"}

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
    curl -Ls public-repo-1.hortonworks.com/HDP/cloudbreak/cloudbreak-deployer_${CBD_VERSION}_$(uname)_x86_64.tgz | tar -xz -C /bin cbd
    mkdir $CBD_DIR
    cd $_
    echo "export PUBLIC_IP=$(curl ifconfig.co)" > Profile
    cbd generate

    cbd pull-parallel
    cbd start
}

execute_shell_script() {
    if [ -n "$SHELL_SCRIPT" ]; then
        wait_for_cloudbreak
        
        cd $CBD_DIR
        echo "$(base64 -d <(echo "$SHELL_SCRIPT"))" | cbd util cloudbreak-shell-quiet
    fi
}

wait_for_cloudbreak() {
    local triesLeft=50
    local ip=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" cbreak_cloudbreak_1)
    while [ -n "$ip" ] && [ -z "$(curl -fs $ip:8080/info)" ] && [ $triesLeft -ne 0 ] ; do
        sleep 5
        triesLeft=$((triesLeft-1))
    done
}

relocate_docker() {
    service docker stop
    rm -rf /var/lib/docker/
    mkdir /mnt/resource/docker
    ln -s /mnt/resource/docker /var/lib/docker
    service docker start
}

main() {
    yum install -y unzip
    check_custom_data
    #relocate_docker
    install_cbd
    if [ "$CBD_VERSION" != "1.0.3" ] && [ "$CBD_VERSION" != "1.1.0" ]; then
        execute_shell_script
    fi
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@" || true
