#!/bin/bash

: ${ARM_USERNAME:?"need to set ARM_USERNAME"}
: ${ARM_PASSWORD:?"need to set ARM_PASSWORD"}
: ${NEW_VERSION:?"need to set NEW_VERSION"}

echo "NEW_VERSION: $NEW_VERSION"

IMAGE_NAME="$(atlas -s sequenceiq/cbd/azure-arm.image --meta cbd_version=$NEW_VERSION -l | jq .metadata.short_image_name -r)"

echo "IMAGE_NAME: $IMAGE_NAME"

IMAGE_VHD="$(bash -c 'docker run -it --rm azuresdk/azure-cli-python:0.2.9 az login --username $ARM_USERNAME --password $ARM_PASSWORD &> /dev/null; \
az storage blob list -c system --account-name sequenceiqnortheurope2 --prefix Microsoft.Compute/Images/packer/$IMAGE_NAME' | jq '.[0].name' -r)"

echo "IMAGE_VHD: $IMAGE_VHD"
echo "OS_IMAGE_SKU_VERSION: $OS_IMAGE_SKU_VERSION"

sigil -f mainTemplate.tmpl VERSION="$NEW_VERSION" IMAGE_VHD="$IMAGE_VHD" OS_IMAGE_SKU_VERSION="$OS_IMAGE_SKU_VERSION" > mainTemplate.json;