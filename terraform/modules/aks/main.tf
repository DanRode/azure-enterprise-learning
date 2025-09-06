# Log Analytics Workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name_prefix}-aks-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

# AKS Cluster - MVP single node configuration
resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.name_prefix}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.name_prefix}-aks"
  
  # Use latest supported version
  kubernetes_version = var.kubernetes_version

  # Single node pool for cost optimization
  default_node_pool {
    name                = "system"
    node_count          = 1
    vm_size             = "Standard_B2s"
    vnet_subnet_id      = var.subnet_id
    
    # Cost optimization settings
    enable_auto_scaling = false
    os_disk_size_gb     = 30
    os_disk_type        = "Managed"
    max_pods            = 30
    
    upgrade_settings {
      max_surge = "1"
    }

    tags = var.tags
  }

  # System assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Network configuration for Azure CNI
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    dns_service_ip = "10.1.0.10"
    service_cidr   = "10.1.0.0/16"
  }

  # Conditional monitoring with Log Analytics
  # Enterprise pattern: Allow disabling for easier cleanup
  dynamic "oms_agent" {
    for_each = var.enable_monitoring ? [1] : []
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    }
  }

  # Disable features to reduce costs
  http_application_routing_enabled = false
  
  # Enable RBAC
  role_based_access_control_enabled = true

  # Azure AD integration (AKS-managed Azure RBAC)
  azure_active_directory_role_based_access_control {
    managed = true
    azure_rbac_enabled = true
  }

  tags = var.tags

  # Ignore version changes to prevent forced upgrades
  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool[0].node_count
    ]
  }
}