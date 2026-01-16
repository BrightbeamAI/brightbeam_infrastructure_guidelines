# Random password for PostgreSQL
resource "random_password" "postgres_password" {
  length  = 32
  special = true
}

# Private DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgres" {
  name                = "${var.project_name}-${var.environment}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "postgres-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id

  tags = var.tags
}

# PostgreSQL Flexible Server with pgvector
resource "azurerm_postgresql_flexible_server" "main" {
  name                          = "psql-${var.project_name}-${var.environment}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.postgres_version
  delegated_subnet_id           = var.postgres_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false
  administrator_login           = "psqladmin"
  administrator_password        = random_password.postgres_password.result
  zone                          = var.postgres_zone
  storage_mb                    = var.postgres_storage_mb
  sku_name                      = var.postgres_sku_name

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]

  tags = var.tags
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = var.database_collation
  charset   = var.database_charset
}

# PostgreSQL Configuration for pgvector extension
resource "azurerm_postgresql_flexible_server_configuration" "pgvector" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "VECTOR"
}

# Service Bus Namespace
resource "azurerm_servicebus_namespace" "main" {
  name                = "sb-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.servicebus_sku

  tags = var.tags
}

# Service Bus Queue
resource "azurerm_servicebus_queue" "main" {
  name         = var.queue_name
  namespace_id = azurerm_servicebus_namespace.main.id

  partitioning_enabled                 = var.queue_enable_partitioning
  dead_lettering_on_message_expiration = true
  max_delivery_count                   = var.queue_max_delivery_count
}
