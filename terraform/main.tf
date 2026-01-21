terraform {
  required_version = ">= 1.0"

  backend "azurerm" {
    # Backend configuration is loaded from environments/{env}/backend.conf
    # Initialize with: terraform init -backend-config=environments/uat/backend.conf
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Common tags
locals {
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# 1. Networking Module
module "networking" {
  source = "./modules/networking"

  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_address_space  = var.vnet_address_space
  subnet_prefixes     = var.subnet_prefixes

  tags = local.common_tags
}

# 2. Observability Module
module "observability" {
  source = "./modules/observability"

  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  log_retention_days  = var.log_retention_days

  tags = local.common_tags
}

# 3. Storage Module
module "storage" {
  source = "./modules/storage"

  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  account_tier        = var.storage_account_tier
  replication_type    = var.storage_replication_type
  blob_containers     = var.blob_containers

  tags = local.common_tags
}

# 4. Container Registry Module
module "container_registry" {
  source = "./modules/container_registry"

  project_name         = var.project_name
  environment          = var.environment
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  sku                  = var.container_registry_sku
  allowed_ip_addresses = var.acr_allowed_ip_addresses
  allowed_subnet_ids = [
    module.networking.container_apps_subnet_id,
    module.networking.functions_subnet_id
  ]
  container_app_identity_principal_id = module.security.container_app_identity_principal_id
  function_app_identity_principal_id  = module.security.function_app_identity_principal_id
  create_container_app_role_assignment = module.security.container_app_identity_principal_id != ""
  create_function_app_role_assignment  = module.security.function_app_identity_principal_id != ""

  tags = local.common_tags
}

# 4b. Image Copy Service Principal Module (for Brightbeam deployment workflow)
module "image_copy_sp" {
  source = "./modules/image_copy_sp"

  project_name                        = var.project_name
  environment                         = var.environment
  create_image_copy_service_principal = var.create_image_copy_service_principal
  image_copy_sp_password_expiry_days  = var.image_copy_sp_password_expiry_days
  container_registry_id               = module.container_registry.container_registry_id

  depends_on = [
    module.container_registry
  ]
}

# 5. Data Platform Module
module "data_platform" {
  source = "./modules/data_platform"

  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_id             = module.networking.vnet_id
  postgres_subnet_id  = module.networking.postgres_subnet_id
  postgres_version    = var.postgres_version
  postgres_sku_name   = var.postgres_sku_name
  postgres_storage_mb = var.postgres_storage_mb
  database_name       = var.database_name
  servicebus_sku      = var.servicebus_sku
  queue_name          = var.queue_name

  tags = local.common_tags
}

# 6. AI Services Module
module "ai_services" {
  source = "./modules/ai_services"

  project_name         = var.project_name
  environment          = var.environment
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  openai_sku           = var.openai_sku
  allowed_ip_addresses = var.openai_allowed_ip_addresses
  allowed_subnet_ids = [
    module.networking.container_apps_subnet_id,
    module.networking.functions_subnet_id
  ]
  gpt_reasoning_model_version = var.gpt_reasoning_model_version
  embeddings_model_version    = var.embeddings_model_version

  tags = local.common_tags
}

# 7. Security Module
module "security" {
  source = "./modules/security"

  project_name               = var.project_name
  environment                = var.environment
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  deployer_object_id         = data.azurerm_client_config.current.object_id
  key_vault_sku              = var.key_vault_sku
  soft_delete_retention_days = var.soft_delete_retention_days
  enable_purge_protection    = var.enable_purge_protection
  allowed_ip_addresses       = var.key_vault_allowed_ip_addresses
  allowed_subnet_ids = [
    module.networking.container_apps_subnet_id,
    module.networking.functions_subnet_id
  ]

  # Pass secrets from other modules
  postgres_password            = module.data_platform.postgres_admin_password
  postgres_connection_string   = module.data_platform.postgres_connection_string
  openai_api_key               = module.ai_services.openai_primary_access_key
  openai_endpoint              = module.ai_services.openai_endpoint
  servicebus_connection_string = module.data_platform.servicebus_connection_string
  acr_username                 = module.container_registry.admin_username
  acr_password                 = module.container_registry.admin_password

  # Pass Brightbeam image-copy service principal credentials (if created)
  image_copy_client_id     = module.image_copy_sp.image_copy_client_id
  image_copy_client_secret = module.image_copy_sp.image_copy_client_secret

  tags = local.common_tags

  depends_on = [
    module.image_copy_sp
  ]
}

# 8. Compute Module
module "compute" {
  source = "./modules/compute"

  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # Dependencies from other modules
  log_analytics_workspace_id             = module.observability.log_analytics_workspace_id
  application_insights_connection_string = module.observability.application_insights_connection_string
  container_apps_subnet_id               = module.networking.container_apps_subnet_id
  functions_subnet_id                    = module.networking.functions_subnet_id
  key_vault_id                           = module.security.key_vault_id
  key_vault_uri                          = module.security.key_vault_uri
  container_registry_login_server        = module.container_registry.login_server
  storage_account_name                   = module.storage.storage_account_name
  functions_storage_account_id           = module.storage.functions_storage_account_id
  functions_storage_account_name         = module.storage.functions_storage_account_name
  container_app_identity_id              = module.security.container_app_identity_id
  container_app_identity_client_id       = module.security.container_app_identity_client_id
  function_app_identity_id               = module.security.function_app_identity_id
  function_app_identity_client_id        = module.security.function_app_identity_client_id
  function_app_identity_principal_id     = module.security.function_app_identity_principal_id

  # Container App configuration
  container_app_image        = var.container_app_image
  container_app_cpu          = var.container_app_cpu
  container_app_memory       = var.container_app_memory
  container_app_min_replicas = var.container_app_min_replicas
  container_app_max_replicas = var.container_app_max_replicas
  container_app_target_port  = var.container_app_target_port

  # Function App configuration
  function_app_sku_name            = var.function_app_sku_name
  function_app_image_name          = var.function_app_image_name
  function_app_image_tag           = var.function_app_image_tag
  function_app_schedule_expression = var.function_app_schedule_expression

  tags = local.common_tags

  depends_on = [
    module.security
  ]
}
