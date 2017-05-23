#!/bin/bash

: ${IMAGE_NAME:?"need to set IMAGE_NAME"}
: ${ARM_USERNAME:?"need to set ARM_USERNAME"}
: ${ARM_PASSWORD:?"need to set ARM_PASSWORD"}

export IMAGE_VHD="$(docker run -it --rm azuresdk/azure-cli-python:0.2.9 az login --username $ARM_USERNAME --password $ARM_PASSWORD &> /dev/null; \
az storage blob list -c system --account-name sequenceiqnortheurope2 --prefix Microsoft.Compute/Images/packer/$IMAGE_NAME | jq '.[0].name' -r | awk '{print $1;}')"

sigil -f mainTemplate.tmpl VERSION="$NEW_VERSION" IMAGE_VHD="$IMAGE_VHD" > mainTemplate.json