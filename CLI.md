# Deeploy via azure CLI

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
 * CBD_VERSION: Version of Cloudbreak (default 1.2.2)
  * You should find a sample Cloudbreak shell command file called `sample-cb-shell-script`. Just replace parameters in `credential create` and `stack create` commands and you are done.
 * DEBUG: Chatty run
 * TRACE: Enable debugging mode

To destroy resource group please execute `ARM_GROUP_NAME_WHAT_I_REALLY_WANT_TO_DELETE=name ./destroy.sh` command.
