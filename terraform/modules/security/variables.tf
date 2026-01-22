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

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "deployer_object_id" {
  description = "Object ID of the deployment principal"
  type        = string
}

variable "key_vault_sku" {
  description = "SKU for Key Vault"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted items"
  type        = number
  default     = 7
}

variable "enable_purge_protection" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

variable "allowed_ip_addresses" {
  description = "List of PUBLIC IP addresses allowed to access Key Vault (rejects private IPs)"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access Key Vault"
  type        = list(string)
  default     = []
}

# Secrets to store
variable "postgres_connection_string" {
  description = "PostgreSQL connection string (includes embedded password)"
  type        = string
  sensitive   = true
}

variable "openai_api_key" {
  description = "Azure OpenAI API key"
  type        = string
  sensitive   = true
}

variable "openai_endpoint" {
  description = "Azure OpenAI endpoint"
  type        = string
}

variable "openai_deployment_name" {
  description = "Azure OpenAI deployment name for GPT model"
  type        = string
}

variable "openai_api_version" {
  description = "Azure OpenAI API version"
  type        = string
  default     = "2024-02-15-preview"
}

variable "embeddings_deployment_name" {
  description = "Azure OpenAI embeddings deployment name"
  type        = string
}

variable "embeddings_api_version" {
  description = "Azure OpenAI embeddings API version"
  type        = string
  default     = "2024-02-15-preview"
}

variable "servicebus_connection_string" {
  description = "Service Bus connection string"
  type        = string
  sensitive   = true
}

variable "acr_username" {
  description = "Container Registry admin username"
  type        = string
  sensitive   = true
}

variable "acr_password" {
  description = "Container Registry admin password"
  type        = string
  sensitive   = true
}

variable "image_copy_client_id" {
  description = "Client ID of the Brightbeam image-copy service principal (optional)"
  type        = string
  default     = ""
}

variable "image_copy_client_secret" {
  description = "Client secret of the Brightbeam image-copy service principal (optional)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
