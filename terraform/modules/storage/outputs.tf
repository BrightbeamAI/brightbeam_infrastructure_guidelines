output "storage_account_id" {
  description = "ID of the main storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Name of the main storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the main storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the main storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "container_names" {
  description = "Names of created blob containers"
  value       = [for c in azurerm_storage_container.containers : c.name]
}

output "functions_storage_account_id" {
  description = "ID of the functions storage account"
  value       = azurerm_storage_account.functions.id
}

output "functions_storage_account_name" {
  description = "Name of the functions storage account"
  value       = azurerm_storage_account.functions.name
}

output "functions_storage_account_primary_access_key" {
  description = "Primary access key for the functions storage account"
  value       = azurerm_storage_account.functions.primary_access_key
  sensitive   = true
}
