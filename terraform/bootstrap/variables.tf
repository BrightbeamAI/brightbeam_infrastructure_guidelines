variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for state resources"
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "Resource group name for Terraform state"
  type        = string
  default     = "rg-terraform-state"
}

variable "storage_account_name" {
  description = "Globally unique storage account name for Terraform state"
  type        = string
}

variable "container_name" {
  description = "Blob container name for Terraform state"
  type        = string
  default     = "tfstate"
}

