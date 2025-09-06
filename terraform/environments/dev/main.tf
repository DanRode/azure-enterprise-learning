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

# Reference shared ACR (enterprise pattern)
# ACR is managed in shared environment and referenced here
data "azurerm_container_registry" "shared" {
  name                = "sharedlearnacr"
  resource_group_name = "shared-learn-rg"
}

# Grant AKS cluster access to shared ACR (enterprise pattern)
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = module.aks.kubelet_identity_object_id
  role_definition_name             = "AcrPull"
  scope                           = data.azurerm_container_registry.shared.id
  skip_service_principal_aad_check = true
}

# Use our AKS module
module "aks" {
  source = "../../modules/aks"
  
  name_prefix         = var.name_prefix
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id          = module.networking.aks_subnet_id
  kubernetes_version = var.kubernetes_version
  enable_monitoring  = var.enable_monitoring
  
  tags = var.tags
}