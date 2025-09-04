#!/bin/bash

# Define variables
RESOURCE_GROUP_NAME="tfstate-rg"
STORAGE_ACCOUNT_NAME="tfstate$(openssl rand -hex 4)"
CONTAINER_NAME="tfstate"
LOCATION="East US"

echo "Creating Terraform backend storage..."

# Create resource group
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location "$LOCATION"

# Create storage account
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob

# Create blob container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME

echo ""
echo "Terraform Backend Configuration:"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Container: $CONTAINER_NAME"
echo ""
echo "SAVE THIS STORAGE ACCOUNT NAME: $STORAGE_ACCOUNT_NAME"