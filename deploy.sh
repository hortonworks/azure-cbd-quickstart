#!/bin/bash

: ${CBD_VERSION:="1.2.0"}

: ${SSH_USERNAME:?SSH user name required}
: ${SSH_PASSWORD:?SSH user password required}

: ${ARM_DEPLOYMENT_NAME:?Deployment name required}
: ${ARM_LOCATION:?Deployment location required}
: ${ARM_GROUP_NAME:?Resource group name required}

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

azure-login() {
    if [[ "$ARM_USERNAME" ]] && [[ "$ARM_PASSWORD" ]]; then
        azure login --username $ARM_USERNAME --password $ARM_PASSWORD
    fi
    azure config mode arm
}

create-group() {
  debug "creating resource group: ${ARM_GROUP_NAME} ..."
  azure group create -n "${ARM_GROUP_NAME}" -l "${ARM_LOCATION}" --tags "Owner=$USER"
}

generate-template() {
    [[ "$CB_SHELL_FILE" ]] && [[ ! -f $CB_SHELL_FILE ]] && echo "Shell command file not found!" && exit 1
    debug "Convert location $ARM_LOCATION id to name"
    local locations=$(azure location list --json | tr -d "\t\n")
    local location_name=$(echo "$locations" | sed -r "s/(.*)$ARM_LOCATION\",\s+\"displayName\":\s+\"([^\"]+)(.*$)/\2/")
    [[ ! "$location_name" ]] || [[ "$locations" = "$location_name" ]] && echo "Location $ARM_LOCATION is invalid!" && exit 1

    debug "generating template to azuredeploy.custom.parameters.json file ..."
    cat azuredeploy.parameters.json | tr -d " \t\n" > azuredeploy.custom.parameters.json
	_replace-json-value cbdVersion $CBD_VERSION
	_replace-json-value location "$location_name"
	_replace-json-value username $SSH_USERNAME
	_replace-json-value password "$SSH_PASSWORD"
	if [[ -f $CB_SHELL_FILE ]]; then
        _replace-json-value cbShellScript "$(base64 $CB_SHELL_FILE)"
	else
        _replace-json-value cbShellScript ""
    fi
    debug "$(<azuredeploy.custom.parameters.json)"
}

_replace-json-value() {
    sed -ri "s/($1\":\{\"value\":\")([^\"]+)(.*$)/\1$2\3/" azuredeploy.custom.parameters.json
}

deploy() {
  debug "deploy ${ARM_DEPLOYMENT_NAME} ..."
  azure group deployment create -f azuredeploy.json -e azuredeploy.custom.parameters.json -g "${ARM_GROUP_NAME}" -n "${ARM_DEPLOYMENT_NAME}"
}

main() {
    azure-login
    create-group
    generate-template
    deploy
}

if [[ "$0" == "$BASH_SOURCE" ]]; then
    main "$@"
    debug "deployment done, thank you for choosing us."
fi
