# Core Configuration
variable "subscription_id" {
  description = "Azure subscription ID - get from 'az account show --query id -o tsv'"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (uat, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "northeurope"
}

variable "key_vault_allowed_ip_addresses" {
  description = <<-EOT
    List of PUBLIC IP addresses or CIDR ranges allowed to access Key Vault.

    ⚠️  Key Vault Restrictions:
    - Rejects private IP ranges (10.x, 172.16-31.x, 192.168.x)
    - Must be valid IPv4 addresses or CIDR notation (e.g., 203.0.113.0/24)

    For Azure resource access (Container Apps, Functions):
    - Leave this empty: key_vault_allowed_ip_addresses = []
    - Access is granted via allowed_subnet_ids automatically

    Example (office/VPN access):
    key_vault_allowed_ip_addresses = ["203.0.113.100"]
  EOT
  type        = list(string)
  default     = []
}

variable "acr_allowed_ip_addresses" {
  description = <<-EOT
    List of IP addresses or CIDR ranges allowed to access Azure Container Registry.

    Note: Only applies when container_registry_sku = "Premium"

    For Azure resource access (Container Apps, Functions):
    - Leave this empty: acr_allowed_ip_addresses = []
    - Managed identities handle authentication automatically

    Example:
    acr_allowed_ip_addresses = ["203.0.113.100", "198.51.100.0/24"]
  EOT
  type        = list(string)
  default     = []
}

variable "openai_allowed_ip_addresses" {
  description = <<-EOT
    List of IP addresses or CIDR ranges allowed to access Azure OpenAI.

    For Azure resource access (Container Apps, Functions):
    - Leave this empty: openai_allowed_ip_addresses = []
    - Access is granted via allowed_subnet_ids automatically

    Example:
    openai_allowed_ip_addresses = ["203.0.113.100"]
  EOT
  type        = list(string)
  default     = []
}

# Networking Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Address prefixes for subnets"
  type = object({
    container_apps    = list(string)
    functions         = list(string)
    postgres          = list(string)
    private_endpoints = list(string)
  })
  default = {
    container_apps    = ["10.0.0.0/23"]
    functions         = ["10.0.2.0/24"]
    postgres          = ["10.0.3.0/24"]
    private_endpoints = ["10.0.4.0/24"]
  }
}

# Observability Configuration
variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 30
}

# Storage Configuration
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "blob_containers" {
  description = "Map of blob container names to access types (private or blob)"
  type        = map(string)
  default = {
    "static" = "blob" # Public read access for CSS/JS/images
    "uploads"     = "private" # Private access for user uploads
  }
}

# Container Registry Configuration
variable "container_registry_sku" {
  description = "SKU for Container Registry"
  type        = string
  default     = "Premium"
}

# Database Configuration
variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "postgres_sku_name" {
  description = "SKU name for PostgreSQL Flexible Server"
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "postgres_storage_mb" {
  description = "Storage size in MB for PostgreSQL"
  type        = number
  default     = 32768
}

variable "database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "appdb"
}

# Service Bus Configuration
variable "servicebus_sku" {
  description = "SKU for Service Bus namespace"
  type        = string
  default     = "Standard"
}

variable "queue_name" {
  description = "Name of the Service Bus queue"
  type        = string
  default     = "data-processing-queue"
}

# AI Services Configuration
variable "openai_sku" {
  description = "SKU for Azure OpenAI"
  type        = string
  default     = "S0"
}

variable "gpt_reasoning_model_version" {
  description = "Model version for GPT-5.1"
  type        = string
  default     = "2025-11-13"
}

variable "embeddings_model_version" {
  description = "Model version for embeddings"
  type        = string
  default     = "1"
}

# Security Configuration
variable "key_vault_sku" {
  description = "SKU for Key Vault"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted Key Vault items"
  type        = number
  default     = 7
}

variable "enable_purge_protection" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

# Container App Configuration
variable "container_app_image" {
  description = "Container image for the application"
  type        = string
  default     = "app:latest"
}

variable "container_app_cpu" {
  description = "CPU allocation for container app"
  type        = number
  default     = 0.5
}

variable "container_app_memory" {
  description = "Memory allocation for container app"
  type        = string
  default     = "1Gi"
}

variable "container_app_min_replicas" {
  description = "Minimum number of container app replicas"
  type        = number
  default     = 1
}

variable "container_app_max_replicas" {
  description = "Maximum number of container app replicas"
  type        = number
  default     = 10
}

variable "container_app_target_port" {
  description = "Target port for container app ingress"
  type        = number
  default     = 8000
}

# Function App Configuration
variable "function_app_sku_name" {
  description = "SKU name for the Function App Service Plan (must be EP1/EP2/EP3 for containers)"
  type        = string
  default     = "EP1"
}

variable "function_app_image_name" {
  description = "Docker image name for function app (leave empty to use Microsoft placeholder image)"
  type        = string
  default     = ""
}

variable "function_app_image_tag" {
  description = "Docker image tag for function app"
  type        = string
  default     = "latest"
}

variable "function_app_schedule_expression" {
  description = "CRON expression for timer-triggered functions (optional, only needed for scheduled triggers)"
  type        = string
  default     = null
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Brightbeam Image Copy Service Principal Configuration
variable "create_image_copy_service_principal" {
  description = "Whether to create the Brightbeam image-copy service principal for this environment"
  type        = bool
  default     = false
}

variable "image_copy_sp_password_expiry_days" {
  description = "Number of days before the image-copy service principal password expires"
  type        = number
  default     = 180
}
