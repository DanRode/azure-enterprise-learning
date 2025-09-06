terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatec18b586c"
    container_name       = "tfstate"
    key                  = "shared/terraform.tfstate"
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

# Create the resource group for shared resources
resource "azurerm_resource_group" "shared" {
  name     = "${var.name_prefix}-rg"
  location = var.location

  tags = var.tags
}

# Azure Container Registry (shared across all environments)
# Enterprise pattern: Single shared ACR with environment tag promotion
resource "azurerm_container_registry" "shared" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.shared.name
  location            = azurerm_resource_group.shared.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled

  # Cost optimization: Basic tier for learning environment
  # Shared across dev/staging/prod with environment tag promotion
  
  tags = merge(var.tags, {
    Service     = "container-registry"
    SharedBy    = "all-environments"
  })
}
