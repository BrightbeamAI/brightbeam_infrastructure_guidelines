# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Networking
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

# Storage
output "storage_account_name" {
  description = "Name of the main storage account"
  value       = module.storage.storage_account_name
}

output "static_ui_url" {
  description = "URL for static UI files"
  value       = "${module.storage.storage_account_primary_blob_endpoint}static-ui/"
}

# Container Registry
output "container_registry_login_server" {
  description = "Login server for Container Registry"
  value       = module.container_registry.login_server
}

# Database
output "postgres_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.data_platform.postgres_fqdn
}

output "postgres_database_name" {
  description = "Name of the PostgreSQL database"
  value       = module.data_platform.postgres_database_name
}

# AI Services
output "openai_endpoint" {
  description = "Endpoint URL for Azure OpenAI"
  value       = module.ai_services.openai_endpoint
}

output "gpt_reasoning_deployment_name" {
  description = "Name of the reasoning model deployment"
  value       = module.ai_services.gpt_reasoning_deployment_name
}

output "embeddings_deployment_name" {
  description = "Name of the embeddings deployment in Azure OpenAI"
  value       = module.ai_services.embeddings_deployment_name
}

# Security
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.security.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.security.key_vault_uri
}

# Compute
output "container_app_url" {
  description = "URL of the Container App"
  value       = module.compute.container_app_url
}

output "container_app_fqdn" {
  description = "FQDN of the Container App"
  value       = module.compute.container_app_fqdn
}

output "function_app_name" {
  description = "Name of the Function App"
  value       = module.compute.function_app_name
}

output "function_app_hostname" {
  description = "Default hostname of the Function App"
  value       = module.compute.function_app_default_hostname
}

# Observability
output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.observability.log_analytics_workspace_name
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.observability.application_insights_instrumentation_key
  sensitive   = true
}
