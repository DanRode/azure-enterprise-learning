variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  validation {
    condition     = length(var.name_prefix) <= 10
    error_message = "Name prefix must be 10 characters or less for AKS naming limits."
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

variable "subnet_id" {
  description = "ID of the subnet for AKS nodes (from networking module)"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = null # Uses latest supported version
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}