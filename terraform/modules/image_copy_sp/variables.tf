variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (uat, prod)"
  type        = string
}

variable "create_image_copy_service_principal" {
  description = "Whether to create the Brightbeam image-copy service principal"
  type        = bool
  default     = false
}

variable "image_copy_sp_password_expiry_days" {
  description = "Number of days before the image-copy service principal password expires"
  type        = number
  default     = 180
}

variable "container_registry_id" {
  description = "Resource ID of the Container Registry to grant AcrPush access"
  type        = string
}
