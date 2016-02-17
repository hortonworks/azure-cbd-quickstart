This repo helps to automate the deployment of Cloudbreak Deployer. On other cloud providers you can create “public images”, while on Azure
its a different process. You have to create a publicly available virtual disk image (vhdi), which has to be downloaded and imported 
into a storage account. Our experience shows that it takes about 30-60 minutes until you can log into the VM.

For Azure we have an alternative approach:
- start from official CentOS, so no image copy is needed
- use [Docker VM Extension](https://github.com/Azure/azure-docker-extension) to install Docker
- use [CustomScript Extension](https://github.com/Azure/azure-linux-extensions/tree/ubuntu/CustomScript) to install Cloudbreak Deployer (cbd)

## Deploy via Azure web UI

Click here: <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsequenceiq%2Fazure-cbd-quickstart%2Fubuntu%2Fazuredeploy.json">  ![deploy on azure](http://azuredeploy.net/deploybutton.png) </a>

## Deeploy via azure CLI

First create an empty resource group:
```
  azure config mode arm
  azure group create -n cbdgroup -l westeurope --tags "Owner=$USER"
```

Download a sample parameter json:
```
curl -LO https://raw.githubusercontent.com/sequenceiq/azure-cbd-quickstart/ubuntu/azuredeploy.parameters.json
```

After editing it, you can deploy by:
```
  azure group deployment create \
    --template-uri https://raw.githubusercontent.com/sequenceiq/azure-cbd-quickstart/ubuntu/azuredeploy.json \
    -e azuredeploy.parameters.json \
    -g cbdgroup \
    -n cbddeployment

```
