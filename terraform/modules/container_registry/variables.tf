variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (uat, prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "sku" {
  description = "SKU for Container Registry"
  type        = string
  default     = "Premium"
}

variable "admin_enabled" {
  description = "Enable admin user for Container Registry"
  type        = bool
  default     = true
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access Container Registry (Premium SKU only)"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the registry"
  type        = list(string)
  default     = []
}

variable "container_app_identity_principal_id" {
  description = "Principal ID of Container App managed identity for ACR access"
  type        = string
  default     = ""
}

variable "function_app_identity_principal_id" {
  description = "Principal ID of Function App managed identity for ACR access"
  type        = string
  default     = ""
}

variable "create_container_app_role_assignment" {
  description = "Whether to create ACR pull role assignment for Container App"
  type        = bool
  default     = false
}

variable "create_function_app_role_assignment" {
  description = "Whether to create ACR pull role assignment for Function App"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
