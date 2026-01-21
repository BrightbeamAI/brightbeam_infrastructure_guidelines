# UAT Environment Configuration

# Azure subscription ID - get from 'az account show --query id -o tsv'
subscription_id = "your-subscription-id-here"

project_name = "my-project"
environment  = "uat"
location     = "northeurope"

# IP Access Control
# ⚠️  Use PUBLIC IPs only for Key Vault (rejects 10.x, 172.16-31.x, 192.168.x)
# For Azure resource access, leave empty and use subnet access
key_vault_allowed_ip_addresses = ["your-public-ip-here"] # Replace with actual IP
acr_allowed_ip_addresses       = []                      # Azure resources use managed identity
openai_allowed_ip_addresses    = []                      # Azure resources use subnet access

# Networking - use default values

# Observability
log_retention_days = 60

# Storage - use defaults

# Container Registry
container_registry_sku = "Standard"

# Database - mid-tier for UAT
postgres_sku_name   = "GP_Standard_D2s_v3"
postgres_storage_mb = 32768
database_name       = "appdb"

# Service Bus
servicebus_sku = "Standard"

# AI Services
openai_sku                  = "S0"
gpt_reasoning_model_version = "2025-11-13"
embeddings_model_version    = "1"

# Security
key_vault_sku              = "standard"
soft_delete_retention_days = 14
enable_purge_protection    = false

# Container App - moderate resources for UAT
container_app_image        = "app:latest"
container_app_cpu          = 0.5
container_app_memory       = "1Gi"
container_app_min_replicas = 1
container_app_max_replicas = 5
container_app_target_port  = 8000

# Function App - Elastic Premium for UAT
function_app_sku_name = "EP1"

# Timer Trigger Configuration (Optional)
# Only needed for scheduled/timer-triggered functions
# For other trigger types (Blob, HTTP, Event Grid, Service Bus), comment out or remove this line
# function_app_schedule_expression = "0 0 6 * * *" # 6 AM daily

# Additional tags
additional_tags = {
  CostCenter = "Engineering"
  Owner      = "DevOps"
}

# Brightbeam Image Copy Service Principal
# Enables Brightbeam deployment workflow to push container images to this ACR
create_image_copy_service_principal = true
image_copy_sp_password_expiry_days  = 180
