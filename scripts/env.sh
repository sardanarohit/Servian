#!/bin/bash

#----------------------------------------------------------------------------------------
# Script to provision environment i.e. create service principal, base resource group
# and storage account
#----------------------------------------------------------------------------------------

#Global Vars
rg="RG_BASE"
storage_account="strgbase$RANDOM"
cont_name="tfstate"
loc="australiaeast"
spn="SPN_AUTOMATION"
kv_name="KV-BASE-$RANDOM"
tags="createdAs=base-resource"
sub_id=$(az account show --query id --output tsv)

# Create Service Principal for Azure Devops
az ad sp create-for-rbac --name $spn --role="Contributor" --scopes="/subscriptions/$sub_id"

# Fetching SPN ID
spn_id=$(az ad sp list --display-name $spn -o tsv --query [].appId)

# Role Assignment for the service principal
az role assignment list --assignee $spn_id --role contributor

# Create base resource group used for storage account only amd keys
az group create --name $rg --location $loc --tag $tags
 
# Create storage account
az storage account create --resource-group $rg --name $storage_account --sku Standard_LRS --encryption-services blob --tag $tags
 
# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $rg --account-name $storage_account --query [0].value -o tsv)
 
# Create blob container
az storage container create --name $cont_name --account-name $storage_account --account-key $ACCOUNT_KEY

# Create Key Vault
az keyvault create --name $kv_name --resource-group $rg --location $loc --tag $tags

# Setting Key Vault Access Policy
az keyvault set-policy  --name $kv_name --spn $spn_id --secret-permissions backup delete get list purge recover restore set

# Setting up password for the vm
az keyvault secret set --vault-name $kv_name --name "password" --value "ofhvndp84hf"