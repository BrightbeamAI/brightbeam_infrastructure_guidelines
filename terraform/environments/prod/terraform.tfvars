# Production Environment Configuration

# Azure subscription ID - get from 'az account show --query id -o tsv'
subscription_id = "your-subscription-id-here"

project_name = "my-project"
environment  = "prod"
location     = "northeurope"

# IP Access Control
# ⚠️  Use PUBLIC IPs only for Key Vault (rejects 10.x, 172.16-31.x, 192.168.x)
# Limit to office/VPN IPs for production security
key_vault_allowed_ip_addresses = ["your-public-ip-here", "your-second-ip-here"] # Replace with actual IPs
acr_allowed_ip_addresses       = []  # Azure resources use managed identity
openai_allowed_ip_addresses    = []  # Azure resources use subnet access

# Networking - use default values

# Observability
log_retention_days = 90

# Storage
storage_account_tier     = "Standard"
storage_replication_type = "GRS" # Geo-redundant for production

# Container Registry
container_registry_sku = "Premium"

# Database - high-performance for production
postgres_sku_name   = "GP_Standard_D4s_v3"
postgres_storage_mb = 65536
database_name       = "appdb"

# Service Bus - Premium for production features
servicebus_sku = "Premium"

# AI Services
openai_sku                  = "S0"
gpt_reasoning_model_version = "2025-11-13"
embeddings_model_version    = "1"

# Security
key_vault_sku              = "standard"
soft_delete_retention_days = 90
enable_purge_protection    = true # Enable for production

# Container App - production-sized resources
container_app_image        = "app:latest"
container_app_cpu          = 1.0
container_app_memory       = "2Gi"
container_app_min_replicas = 2 # Always have at least 2 for HA
container_app_max_replicas = 20
container_app_target_port  = 8000

# Function App - Elastic Premium 2 for production
function_app_sku_name = "EP2"

# Timer Trigger Configuration (Optional)
# Only needed for scheduled/timer-triggered functions
# For other trigger types (Blob, HTTP, Event Grid, Service Bus), comment out or remove this line
# function_app_schedule_expression = "0 0 6 * * *" # 6 AM daily

# Additional tags
additional_tags = {
  CostCenter  = "Production"
  Owner       = "Platform"
  Criticality = "High"
}

# Brightbeam Image Copy Service Principal
# Enables Brightbeam deployment workflow to push container images to this ACR
create_image_copy_service_principal = true
image_copy_sp_password_expiry_days  = 180
