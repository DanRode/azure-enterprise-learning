# Shared Environment Configuration
# These resources are shared across dev/staging/prod environments

name_prefix = "shared-learn"
location    = "East US"

# Azure Container Registry settings
acr_name         = "sharedlearnacr"
acr_sku          = "Basic"
acr_admin_enabled = false

# Tags for shared resources
tags = {
  Environment = "shared"
  Project     = "azure-enterprise-learning" 
  ManagedBy   = "terraform"
  Purpose     = "shared-services"
  CostCenter  = "learning"
}
