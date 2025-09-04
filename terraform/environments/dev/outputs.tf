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