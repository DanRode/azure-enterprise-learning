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

variable "tags" {
  description = "Tags for dev environment resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "azure-learning"
    ManagedBy   = "terraform"
  }
}