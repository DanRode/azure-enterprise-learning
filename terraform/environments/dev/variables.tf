variable "name_prefix" {
  description = "Prefix for resource names in dev environment"
  type        = string
  default     = "dev-learn"
}

variable "location" {
  description = "Azure region for dev environment"
  type        = string
  default     = "East US"
}

variable "vnet_address_space" {
  description = "Address space for dev VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = null # Uses latest supported version
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor for containers. Set to false for easier cleanup during learning."
  type        = bool
  default     = false # Disabled by default for easier cleanup
}

variable "tags" {
  description = "Tags for dev environment resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "azure-enterprise-learning"
    ManagedBy   = "terraform"
  }
}