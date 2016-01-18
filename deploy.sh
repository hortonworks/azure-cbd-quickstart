#!/bin/bash

set -eo pipefail
if [[ "$TRACE" ]]; then
    : ${START_TIME:=$(date +%s)}
    export START_TIME
    export PS4='+ [TRACE $BASH_SOURCE:$LINENO][ellapsed: $(( $(date +%s) -  $START_TIME ))] '
    set -x
fi

debug() {
  [[ "$DEBUG" ]] && echo "-----> $*" 1>&2
}

createGroup() {
  debug "creating resource group: ${groupName} ..."
  azure config mode arm
  azure group create -n "${groupName}" -l "${region}" --tags "Owner=$USER"
}

deploy() {
  debug "deploy ..."
  azure group deployment create -f azuredeploy.json -e azuredeploy.parameters.json -g "${groupName}" -n "${deploymentName}"
}

destroy() {
  azure group delete $groupName -q
}

log() {
    # azure group log show  cbd-rm-test --json| jq '.[]|[.resourceUri,.eventName,.status]' -c| sed 's:/subscriptions/947dafa0-8a1d-4ac9-909b-c71a0fa03ea6/resourcegroups/cbd-rm-test:cbd-rm-test:'
    azure group deployment operation list  "${groupName}" "${deploymentName}" --json| jq '.[].properties|[.targetResource.resourceType,.provisioningState,.statusCode]' -c
}

deploy_rm(){
    declare groupName=${1:? groupName required}
    azure group create  -l westeurope -n $groupName
    azure group deployment create  -f azuredeploy.json -e azuredeploy.parameters.json -g $groupName -n vasardeploy
}

main() {
  deploymentName=cbd-rm-weekend
  groupName="cbd-rm-test-2"
  region="westeurope"
  #createGroup
  deploy
  azure group log show -l -v "${groupName}"
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@" || true
