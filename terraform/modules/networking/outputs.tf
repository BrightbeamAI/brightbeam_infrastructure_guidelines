output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "container_apps_subnet_id" {
  description = "ID of the container apps subnet"
  value       = azurerm_subnet.container_apps.id
}

output "functions_subnet_id" {
  description = "ID of the functions subnet"
  value       = azurerm_subnet.functions.id
}

output "postgres_subnet_id" {
  description = "ID of the postgres subnet"
  value       = azurerm_subnet.postgres.id
}

output "private_endpoints_subnet_id" {
  description = "ID of the private endpoints subnet"
  value       = azurerm_subnet.private_endpoints.id
}
