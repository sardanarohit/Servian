***
# Servian DevOps Tech Challenge - Tech Challenge App

***
## Overview

The solution consists of base resources via Azure CLI commands through a script and using the Terraform for building the infrastructure with custom extension, which manages a Virtual Machine - to provide post deployment configuration and run automated tasks.

I have used Azure DevOps Releases to deploy the Terraform script on the Azure portal.
 
## Prerequisites (cost involved)

1. Azure Subscription (Yes)
2. Azure DevOps account (No)
3. GitHub Account (No)

## Repository Structure
````

│────── scripts                           # Scripts directory 
│       ├── env.sh                        # Script to provision Base Resources used in solution
│       ├── install.sh                    # Virtual Machine Extension script to provide post deployment configuration and run automated tasks.
├────── vm                                # Terraform Scripts directory 
│       ├── dataresources.tf              # Data resources script
│       ├── main.tf                       # main script 
│       ├── variables.tf                  # scripts for all the variables
│       ├── vm.tf                         # main module script to create the VM
│───── images                             # Images directoryn for readme
````

## The solution consists of three parts:
1. For creating the base resources - implemented via running one script - 'env.sh'
2. For creating all the Azure Resources - used Terraform as IAAC
3. For deploying the resources on the Azure Cloud by Azure DevOps 

## Architecture  

I am taking the approach for building and deploying the code on linux VM using the custom extension script - 'install.sh' which is used for post deployment of resources.

1. First thing  I have created a script - 'env.sh' which will create base resources as follows 
    1. Service Principal - for integrating Azure DevOps and Azure resources
    2. Base Resource Group - For Creating base resources
    3. Storage Account - for storing the state file
    4. KeyVault - to store the secret of the VM
2. Setting up of Azure Devops
    1. Create a Service connections
    2. Setup agent pool to run your release jobs
    3. Create Release pipeline with four tasks
       1. Terraform init
       2. Terraform validate
       3. Terraform plan
       4. Terraform apply
3. From the artifacts section in the release, create a service connection with the GitHub Account and integrate the source repo
4. In the Pre-deployment conditions set it to manual trigger and add the approvals (optional in this case)   
![](https://github.com/sardanarohit/Servian/blob/read/images/release.png)

## Scripts Walkthrough

### Servian/scripts/env.sh

First part is variables
example below

```
rg="RG_BASE"
storage_account="strgbase$RANDOM"
cont_name="tfstate"
loc="australiaeast"
``` 
Second part is Azure CLI commands
example below

```
# Fetching SPN ID
spn_id=$(az ad sp list --display-name $spn -o tsv --query [].appId)

# Role Assignment for the service principal
az role assignment list --assignee $spn_id --role contributor

# Create base resource group used for storage account only amd keys
az group create --name $rg --location $loc --tag $tags
 
# Create storage account
az storage account create --resource-group $rg --name $storage_account --sku Standard_LRS --encryption-services blob --tag $tags
```

### Servian/scripts/install.sh

It consists of four steps
1. Downloading and installing PostgreSQL
2. configuring the env, downloading and configuring Go
3. Building and Deploying the app
4. Running the app

### Servian/vm

It consist of four terraform scripts
1.  dataresources.tf - Data resources script which we created using base script
2.  main.tf - main script for initializing the provider                     
3.  variables.tf - scripts for all the variables used in the main module
    a. used one prefix variable as suffix for all the resources
    b. used list(object) variable for NSG rules
    c. used map variable in case of tags
4.  vm.tf - Please see below the key poinnts 
    a. Created all the resources in this script
    b. All the values are stored in variable.tf
    c. Used Dynamic blocks to avoid repetetion while creating NSG rules
    d. used custom script as extension to manage post deployment


## Post Deployment

Navifate to the azure portal and to the new resource group which has been created by the terraform script.

Verify the provisioing of all the resources

Navigate to the VM and copy the Public IP

Open the web browser to launch the application and paste "Public IP:3000"

![](https://github.com/sardanarohit/Servian/blob/read/images/app.png)

### Logs and directory structure

Login via putty - you can get the credentials and log in details from the variable.tf

Some of the useful paths

1. Go path --->             ``/usr/local/go/bin``
2. Postgress Path --->      ``/var/lib/postgresql/``
3. Application Path --->    ``/var/lib/waagent/custom-script/download/0/TechChallengeApp``
4. Deployment logs  --->    ``/var/lib/waagent/custom-script/download/0/stdout``

![](https://github.com/sardanarohit/Servian/blob/read/images/logs.png)
