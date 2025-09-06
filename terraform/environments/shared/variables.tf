variable "name_prefix" {
  description = "Prefix for shared resource names"
  type        = string
  default     = "shared-learn"
}

variable "location" {
  description = "Azure region for shared resources"
  type        = string
  default     = "East US"
}

variable "acr_name" {
  description = "Name for Azure Container Registry (must be globally unique)"
  type        = string
  default     = "sharedlearnacr"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.acr_name))
    error_message = "ACR name must contain only alphanumeric characters."
  }
  
  validation {
    condition     = length(var.acr_name) >= 5 && length(var.acr_name) <= 50
    error_message = "ACR name must be between 5 and 50 characters long."
  }
}

variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Basic"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "acr_admin_enabled" {
  description = "Enable admin user for ACR (use service principals in production)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for shared resources"
  type        = map(string)
  default = {
    Environment = "shared"
    Project     = "azure-enterprise-learning"
    ManagedBy   = "terraform"
    Purpose     = "shared-services"
  }
}
