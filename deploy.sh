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
  azure group create -n "${groupName}" -l "${region}"
}

deploy() {
  debug "deploy ..."
  azure group deployment create -f azuredeploy.json -e azuredeploy.parameters.json -g "${groupName}" -n "${deploymentName}"
}

destroy() {
  azure group delete $groupName -q
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
