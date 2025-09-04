variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  validation {
    condition     = length(var.name_prefix) <= 10
    error_message = "Name prefix must be 10 characters or less."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}