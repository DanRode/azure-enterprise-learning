terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatec18b586c"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create the resource group for dev environment
resource "azurerm_resource_group" "main" {
  name     = "${var.name_prefix}-rg"
  location = var.location

  tags = var.tags
}

# Use our networking module
module "networking" {
  source = "../../modules/networking"
  
  name_prefix         = var.name_prefix
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_address_space = var.vnet_address_space
  
  tags = var.tags
}

# Use our AKS module
module "aks" {
  source = "../../modules/aks"
  
  name_prefix         = var.name_prefix
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id          = module.networking.aks_subnet_id
  kubernetes_version = var.kubernetes_version
  
  tags = var.tags
}