# Local variables
locals {
  # Use placeholder image if custom image not provided
  use_custom_function_image = var.function_app_image_name != ""
  function_registry_url     = local.use_custom_function_image ? "https://${var.container_registry_login_server}" : "https://mcr.microsoft.com"
  function_image_name       = local.use_custom_function_image ? var.function_app_image_name : "azure-functions/python"
  function_image_tag        = local.use_custom_function_image ? var.function_app_image_tag : "4-python3.11"
}

# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.project_name}-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  infrastructure_subnet_id   = var.container_apps_subnet_id

  tags = var.tags
}

# Container App
resource "azurerm_container_app" "main" {
  name                         = "ca-${var.container_app_name}-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.container_app_identity_id
    ]
  }

  template {
    container {
      name = var.container_app_name
      # Use placeholder until actual image is pushed to ACR
      image  = var.container_app_image != "" ? "${var.container_registry_login_server}/${var.container_app_image}" : "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = var.container_app_cpu
      memory = var.container_app_memory

      env {
        name  = "AZURE_KEY_VAULT_URL"
        value = var.key_vault_uri
      }

      env {
        name  = "AZURE_CLIENT_ID"
        value = var.container_app_identity_client_id
      }

      env {
        name  = "POSTGRES_CONNECTION_STRING_SECRET"
        value = "postgres-connection-string"
      }

      env {
        name  = "OPENAI_API_KEY_SECRET"
        value = "openai-api-key"
      }

      env {
        name  = "OPENAI_ENDPOINT_SECRET"
        value = "openai-endpoint"
      }

      env {
        name  = "STORAGE_ACCOUNT_NAME"
        value = var.storage_account_name
      }
    }

    min_replicas = var.container_app_min_replicas
    max_replicas = var.container_app_max_replicas
  }

  ingress {
    external_enabled = true
    target_port      = var.container_app_target_port

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server   = var.container_registry_login_server
    identity = var.container_app_identity_id
  }

  tags = var.tags
}

# App Service Plan for Function App
resource "azurerm_service_plan" "functions" {
  name                = "asp-functions-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.function_app_sku_name

  tags = var.tags
}

# Linux Function App (Containerized with Managed Identity)
resource "azurerm_linux_function_app" "main" {
  name                = "func-${var.function_app_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.functions.id
  storage_account_name = var.functions_storage_account_name

  # Use managed identity for storage access (no access key needed)
  storage_uses_managed_identity = true

  # VNet integration only supported with Premium plans (EP1/EP2/EP3), not consumption (Y1)
  virtual_network_subnet_id = var.function_app_sku_name != "Y1" ? var.functions_subnet_id : null

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.function_app_identity_id
    ]
  }

  site_config {
    # Use Docker container instead of Python runtime
    application_stack {
      docker {
        registry_url = local.function_registry_url
        image_name   = local.function_image_name
        image_tag    = local.function_image_tag
      }
    }

    application_insights_connection_string = var.application_insights_connection_string

    # Use managed identity for ACR access (only when using custom image)
    acr_use_managed_identity_credentials = local.use_custom_function_image
    acr_user_managed_identity_client_id  = local.use_custom_function_image ? var.function_app_identity_client_id : null
  }

  app_settings = merge({
    # Azure Functions runtime configuration (required for containers)
    "FUNCTIONS_WORKER_RUNTIME"            = "python"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"

    # Managed identity for storage account (replaces connection string)
    "AzureWebJobsStorage__accountName" = var.functions_storage_account_name

    # Managed identity configuration for SDK-based Key Vault access
    "AZURE_KEY_VAULT_URL" = var.key_vault_uri
    "AZURE_CLIENT_ID"     = var.function_app_identity_client_id
    }, var.function_app_schedule_expression != null ? {
    # Application configuration - timer trigger (optional)
    "SCHEDULE_EXPRESSION" = var.function_app_schedule_expression
  } : {})

  tags = var.tags

  # Ensure role assignments complete before function app deployment
  depends_on = [
    azurerm_role_assignment.function_app_storage_blob,
    azurerm_role_assignment.function_app_key_vault
  ]
}

# Grant Storage Blob Data Owner role to Function App managed identity
# Required for storage_uses_managed_identity = true
resource "azurerm_role_assignment" "function_app_storage_blob" {
  scope                = var.functions_storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.function_app_identity_principal_id
}

# Grant Key Vault Secrets User role to Function App managed identity
# Required for SDK-based secret retrieval (Azure SDK SecretClient)
resource "azurerm_role_assignment" "function_app_key_vault" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.function_app_identity_principal_id
}
