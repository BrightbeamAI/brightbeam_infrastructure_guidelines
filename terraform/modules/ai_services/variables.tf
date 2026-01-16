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

variable "openai_sku" {
  description = "SKU for Azure OpenAI"
  type        = string
  default     = "S0"
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access Azure OpenAI"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access OpenAI"
  type        = list(string)
  default     = []
}

variable "gpt_reasoning_model_name" {
  description = "Model name for reasoning model (GPT-5.1)"
  type        = string
  default     = "gpt-5.1"
}

variable "gpt_reasoning_model_version" {
  description = "Model version for GPT-5.1"
  type        = string
  default     = "2025-11-13"
}

variable "gpt_reasoning_deployment_name" {
  description = "Deployment name for reasoning model"
  type        = string
  default     = "gpt-5.1"
}

variable "embeddings_model_name" {
  description = "Model name for embeddings"
  type        = string
  default     = "text-embedding-3-small"
}

variable "embeddings_model_version" {
  description = "Model version for embeddings"
  type        = string
  default     = "2"
}

variable "embeddings_deployment_name" {
  description = "Deployment name for embeddings"
  type        = string
  default     = "text-embedding-3-small"
}

variable "deployment_scale_type" {
  description = "Scale type for deployments"
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
