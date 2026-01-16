output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "container_app_identity_id" {
  description = "ID of the container app managed identity"
  value       = azurerm_user_assigned_identity.container_app.id
}

output "container_app_identity_client_id" {
  description = "Client ID of the container app managed identity"
  value       = azurerm_user_assigned_identity.container_app.client_id
}

output "container_app_identity_principal_id" {
  description = "Principal ID of the container app managed identity"
  value       = azurerm_user_assigned_identity.container_app.principal_id
}

output "function_app_identity_id" {
  description = "ID of the function app managed identity"
  value       = azurerm_user_assigned_identity.function_app.id
}

output "function_app_identity_client_id" {
  description = "Client ID of the function app managed identity"
  value       = azurerm_user_assigned_identity.function_app.client_id
}

output "function_app_identity_principal_id" {
  description = "Principal ID of the function app managed identity"
  value       = azurerm_user_assigned_identity.function_app.principal_id
}
