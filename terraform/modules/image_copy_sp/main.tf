terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

# Data source for current client config
data "azurerm_client_config" "current" {}

# ============================================================================
# Service Principal for Deploying Container Image (Brightbeam Deployment Workflow)
# ============================================================================
# This service principal allows Brightbeam's deployment workflow to push
# container images from their dev ACR to a customer's ACR in their Azure tenant.
# 
# Security: Scoped to AcrPush permission only (least privilege)
# ============================================================================

# App Registration for Image Deploy
resource "azuread_application" "image_copy" {
  count        = var.create_image_copy_service_principal ? 1 : 0
  display_name = "${var.project_name}-${var.environment}-image-copy"
  description  = "Service Principal for Brightbeam Deployment Pipeline to copy container images to customer ACR"

  tags = [
    "ImageCopy",
    "Brightbeam"
  ]
}

# Service Principal for the App Registration
resource "azuread_service_principal" "image_copy" {
  count     = var.create_image_copy_service_principal ? 1 : 0
  client_id = azuread_application.image_copy[0].client_id

  tags = [
    "ImageCopy",
    "Brightbeam"
  ]
}

# Generate a password for the Service Principal
resource "azuread_application_password" "image_copy" {
  count             = var.create_image_copy_service_principal ? 1 : 0
  application_id    = azuread_application.image_copy[0].id
  display_name      = "Brightbeam Deploy Password"
  end_date_relative = "${var.image_copy_sp_password_expiry_days * 24}h"
}

# Grant AcrPush role to the Service Principal on the Container Registry
resource "azurerm_role_assignment" "image_copy_acr_push" {
  count                = var.create_image_copy_service_principal ? 1 : 0
  scope                = var.container_registry_id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.image_copy[0].object_id
  principal_type       = "ServicePrincipal"
}
