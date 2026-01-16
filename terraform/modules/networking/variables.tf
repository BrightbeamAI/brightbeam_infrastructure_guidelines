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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
