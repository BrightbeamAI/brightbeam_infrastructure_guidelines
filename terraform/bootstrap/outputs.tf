output "resource_group_name" {
  value       = azurerm_resource_group.state.name
  description = "Resource group for Terraform state"
}

output "storage_account_name" {
  value       = azurerm_storage_account.state.name
  description = "Storage account for Terraform state"
}

output "container_name" {
  value       = azurerm_storage_container.state.name
  description = "Blob container for Terraform state"
}

