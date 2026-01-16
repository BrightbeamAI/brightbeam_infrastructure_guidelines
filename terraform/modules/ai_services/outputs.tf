output "openai_account_id" {
  description = "ID of the Azure OpenAI account"
  value       = azurerm_cognitive_account.openai.id
}

output "openai_endpoint" {
  description = "Endpoint URL for Azure OpenAI"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "openai_primary_access_key" {
  description = "Primary access key for Azure OpenAI"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}

output "openai_secondary_access_key" {
  description = "Secondary access key for Azure OpenAI"
  value       = azurerm_cognitive_account.openai.secondary_access_key
  sensitive   = true
}

output "gpt_reasoning_deployment_name" {
  description = "Name of the reasoning model deployment"
  value       = azurerm_cognitive_deployment.gpt_reasoning.name
}

# Commented out because embeddings deployment is disabled due to quota
# output "embeddings_deployment_name" {
#   description = "Name of the embeddings deployment"
#   value       = azurerm_cognitive_deployment.embeddings.name
# }
