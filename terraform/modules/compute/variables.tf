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

# Dependencies
variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  type        = string
}

variable "container_apps_subnet_id" {
  description = "Subnet ID for Container Apps"
  type        = string
}

variable "functions_subnet_id" {
  description = "Subnet ID for Functions"
  type        = string
}

variable "key_vault_id" {
  description = "ID of the Key Vault (for role assignments)"
  type        = string
}

variable "key_vault_uri" {
  description = "URI of the Key Vault"
  type        = string
}

variable "container_registry_login_server" {
  description = "Login server for Container Registry"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "functions_storage_account_id" {
  description = "ID of the storage account for functions"
  type        = string
}

variable "functions_storage_account_name" {
  description = "Name of the storage account for functions"
  type        = string
}

variable "function_app_identity_principal_id" {
  description = "Principal ID of function app managed identity (for role assignments)"
  type        = string
}

variable "container_app_identity_id" {
  description = "Managed identity ID for container app"
  type        = string
}

variable "container_app_identity_client_id" {
  description = "Client ID of container app managed identity"
  type        = string
}

variable "function_app_identity_id" {
  description = "Managed identity ID for function app"
  type        = string
}

variable "function_app_identity_client_id" {
  description = "Client ID of function app managed identity"
  type        = string
}

# Container App Configuration
variable "container_app_name" {
  description = "Name of the container app"
  type        = string
  default     = "qa-app"
}

variable "container_app_image" {
  description = "Container image for the app"
  type        = string
  default     = "qa-app:latest"
}

variable "container_app_cpu" {
  description = "CPU allocation for container app"
  type        = number
  default     = 0.5
}

variable "container_app_memory" {
  description = "Memory allocation for container app"
  type        = string
  default     = "1Gi"
}

variable "container_app_min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 1
}

variable "container_app_max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 10
}

variable "container_app_target_port" {
  description = "Target port for ingress"
  type        = number
  default     = 8000
}

# Function App Configuration
variable "function_app_name" {
  description = "Name of the function app"
  type        = string
  default     = "data-processor"
}

variable "function_app_sku_name" {
  description = "SKU name for the App Service Plan"
  type        = string
  default     = "EP1"
}

variable "function_app_image_name" {
  description = "Docker image name for function app (leave empty to use Microsoft placeholder)"
  type        = string
  default     = ""
}

variable "function_app_image_tag" {
  description = "Docker image tag for function app"
  type        = string
  default     = "latest"
}

variable "function_app_schedule_expression" {
  description = "CRON expression for timer-triggered functions (optional, only needed for scheduled triggers)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
