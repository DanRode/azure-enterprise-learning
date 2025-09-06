output "resource_group_name" {
  description = "Name of the dev resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the dev resource group"
  value       = azurerm_resource_group.main.id
}

output "vnet_id" {
  description = "ID of the dev VNet"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the dev VNet"
  value       = module.networking.vnet_name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = module.networking.aks_subnet_id
}

output "database_subnet_id" {
  description = "ID of the database subnet"
  value       = module.networking.database_subnet_id
}

# AKS outputs
output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.cluster_fqdn
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.aks.cluster_id
}

# ACR outputs (shared enterprise pattern - referenced from shared environment)
output "acr_name" {
  description = "Name of the shared Azure Container Registry"
  value       = data.azurerm_container_registry.shared.name
}

output "acr_login_server" {
  description = "Login server URL for the shared Azure Container Registry"
  value       = data.azurerm_container_registry.shared.login_server
}

output "acr_id" {
  description = "ID of the shared Azure Container Registry"
  value       = data.azurerm_container_registry.shared.id
}