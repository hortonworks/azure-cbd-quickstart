This repo helps to automate the deployment of Cloudbreak Deployer. On other cloudproviders you can create “public images”, while on azure
its a different process. You have to create a publicly available virtual disk image (vhdi), which has to be downloaded, imported 
into a storage account. Our experience shpw that it takes about 30-60 minutes until you can log into the VM.

For Azure we have an alternative approach:
- start from official CentOS, so no image copy is needed
- use [Docker VM Extension](https://github.com/Azure/azure-docker-extension) to install Docker
- use [CustomScript Extension](https://github.com/Azure/azure-linux-extensions/tree/master/CustomScript) to install CloudbreakDeployer (cbd)

## Deploy via Azure web UI

Click [here](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsequenceiq%2Fazure-cbd-quickstart%2Fmaster%2Fazuredeploy.json)


## Deeploy vi azure cli

First create an empty resource group:
```
  azure config mode arm
  azure group create -n cbdgroup -l westeurope --tags "Owner=$USER"
```

Download a sample parameter json:
```
curl -LO https://raw.githubusercontent.com/sequenceiq/azure-cbd-quickstart/master/azuredeploy.parameters.json
```

After editing it, you can deploy by:
```
  azure group deployment create \
    --template-uri https://raw.githubusercontent.com/sequenceiq/azure-cbd-quickstart/master/azuredeploy.json \
    -e azuredeploy.parameters.json \
    -g cbdgroup \
    -n cbddeployment

```
