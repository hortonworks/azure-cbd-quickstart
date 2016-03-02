This repo helps to automate the deployment of Cloudbreak Deployer. On other cloud providers you can create “public images”, while on Azure
its a different process. You have to create a publicly available virtual disk image (vhdi), which has to be downloaded and imported 
into a storage account. Our experience shows that it takes about 30-60 minutes until you can log into the VM.

For Azure we have an alternative approach:
- start from official CentOS, so no image copy is needed
- use [Docker VM Extension](https://github.com/Azure/azure-docker-extension) to install Docker
- use [CustomScript Extension](https://github.com/Azure/azure-linux-extensions/tree/master/CustomScript) to install Cloudbreak Deployer (cbd)

## Deploy via Azure web UI

Click here: <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsequenceiq%2Fazure-cbd-quickstart%2Fmaster%2Fazuredeploy.json">  ![deploy on azure](http://azuredeploy.net/deploybutton.png) </a>

## Deeploy via azure CLI

CLI tool requires some parameter to run properly:

 * SSH_USERNAME: User name on the running instance
 * SSH_PASSWORD: Password of the user
 * ARM_DEPLOYMENT_NAME: Name of the deployment
 * ARM_LOCATION: Name of the target location - **important: not the Display Name** -, for details call `azure location list`
 * ARM_GROUP_NAME: Name of resource group
 
```
SSH_USERNAME=$SSH_USERNAME \
SSH_PASSWORD=$SSH_PASSWORD \
ARM_DEPLOYMENT_NAME=$ARM_DEPLOYMENT_NAME \
ARM_LOCATION=$ARM_LOCATION \
ARM_GROUP_NAME=$ARM_GROUP_NAME \
./deploy.sh
```

There are some optional parameters:

 * ARM_USERNAME: If login required, the username of the Azure user (default empty)
 * ARM_PASSWORD: If login required, the password of the Azure user (default empty)
 * CB_SHELL_FILE: Cloudbreak shell command file to execute on the new deployment (default empty)
 * CBD_VERSION: Version of Cloudbreak (default 1.1.0)
  * You should find a sample Cloudbreak shell command file called `sample-cb-shell-script`. Just replace parameters in `credential create` and `stack create` commands and you are done.
 * DEBUG: Chatty run
 * TRACE: Enable debugging mode
 
To destroy resource group please execute `ARM_GROUP_NAME_WHAT_I_REALLY_WANT_TO_DELETE=name ./destroy.sh` command.
