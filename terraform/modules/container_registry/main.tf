# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "cr${replace(var.project_name, "-", "")}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # Network rules only available for Premium SKU
  # In provider v4.0, virtual_network block has been removed
  # Virtual network access should be configured via Private Endpoints instead
  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" && length(var.allowed_ip_addresses) > 0 ? [1] : []
    content {
      default_action = "Deny"

      dynamic "ip_rule" {
        for_each = toset(var.allowed_ip_addresses)
        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }
    }
  }

  tags = var.tags
}

# Grant AcrPull role to Container App managed identity
resource "azurerm_role_assignment" "container_app_acr_pull" {
  count                = var.create_container_app_role_assignment ? 1 : 0
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = var.container_app_identity_principal_id
}

# Grant AcrPull role to Function App managed identity
resource "azurerm_role_assignment" "function_app_acr_pull" {
  count                = var.create_function_app_role_assignment ? 1 : 0
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = var.function_app_identity_principal_id
}
