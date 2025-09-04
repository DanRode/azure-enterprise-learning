# Dev environment configuration
name_prefix = "dev-learn"
location    = "East US"

# Network configuration
vnet_address_space = "10.0.0.0/16"

# Environment tags
tags = {
  Environment = "dev"
  Project     = "azure-learning"
  ManagedBy   = "terraform"
  Owner       = "learning-project"
}