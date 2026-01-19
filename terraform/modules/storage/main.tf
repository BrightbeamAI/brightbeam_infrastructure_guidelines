# Main Storage Account for Static Files
resource "azurerm_storage_account" "main" {
  name                     = "st${replace(var.project_name, "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = var.cors_allowed_methods
      allowed_origins    = var.cors_allowed_origins
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  tags = var.tags
}

# Blob Containers
resource "azurerm_storage_container" "containers" {
  for_each = var.blob_containers

  name                  = each.key
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = each.value
}

# Storage Account for Function App
resource "azurerm_storage_account" "functions" {
  name                     = "stfunc${replace(var.project_name, "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type

  tags = var.tags
}
