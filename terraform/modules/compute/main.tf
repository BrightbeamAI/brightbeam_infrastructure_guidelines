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

# Linux Function App
resource "azurerm_linux_function_app" "main" {
  name                       = "func-${var.function_app_name}-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.functions.id
  storage_account_name       = var.functions_storage_account_name
  storage_account_access_key = var.functions_storage_account_key

  # VNet integration only supported with Premium plans (EP1/EP2/EP3), not consumption (Y1)
  virtual_network_subnet_id = var.function_app_sku_name != "Y1" ? var.functions_subnet_id : null

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.function_app_identity_id
    ]
  }

  site_config {
    application_stack {
      python_version = var.function_app_python_version
    }

    application_insights_connection_string = var.application_insights_connection_string
  }

  app_settings = {
    "AZURE_KEY_VAULT_URL"                 = var.key_vault_uri
    "AZURE_CLIENT_ID"                     = var.function_app_identity_client_id
    "POSTGRES_CONNECTION_STRING_SECRET"   = "postgres-connection-string"
    "OPENAI_API_KEY_SECRET"               = "openai-api-key"
    "OPENAI_ENDPOINT_SECRET"              = "openai-endpoint"
    "SERVICEBUS_CONNECTION_STRING_SECRET" = "servicebus-connection-string"
    "SCHEDULE_EXPRESSION"                 = var.function_app_schedule_expression
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${var.container_registry_login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = var.container_registry_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = var.container_registry_password
  }

  tags = var.tags
}
