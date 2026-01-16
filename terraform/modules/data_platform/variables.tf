variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (uat, prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "postgres_subnet_id" {
  description = "Subnet ID for PostgreSQL delegation"
  type        = string
}

variable "vnet_id" {
  description = "Virtual Network ID for Private DNS zone linking"
  type        = string
}

# PostgreSQL Configuration
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

variable "postgres_zone" {
  description = "Availability zone for PostgreSQL"
  type        = string
  default     = "1"
}

variable "database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "appdb"
}

variable "database_collation" {
  description = "Collation for the database"
  type        = string
  default     = "en_US.utf8"
}

variable "database_charset" {
  description = "Character set for the database"
  type        = string
  default     = "UTF8"
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

variable "queue_enable_partitioning" {
  description = "Enable partitioning for the queue"
  type        = bool
  default     = true
}

variable "queue_max_delivery_count" {
  description = "Maximum delivery count before moving to dead letter queue"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
