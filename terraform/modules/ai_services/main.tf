# Azure OpenAI Cognitive Account
resource "azurerm_cognitive_account" "openai" {
  name                  = "oai-${var.project_name}-${var.environment}"
  location              = "swedencentral" # OpenAI only available in specific regions
  resource_group_name   = var.resource_group_name
  kind                  = "OpenAI"
  sku_name              = var.openai_sku
  custom_subdomain_name = "oai-${var.project_name}-${var.environment}"

  dynamic "network_acls" {
    for_each = length(var.allowed_ip_addresses) > 0 || length(var.allowed_subnet_ids) > 0 ? [1] : []
    content {
      default_action = "Deny"
      ip_rules       = var.allowed_ip_addresses

      dynamic "virtual_network_rules" {
        for_each = var.allowed_subnet_ids
        content {
          subnet_id = virtual_network_rules.value
        }
      }
    }
  }

  tags = var.tags
}

# Azure OpenAI Deployment for GPT-5.1 (Reasoning Model)
resource "azurerm_cognitive_deployment" "gpt_reasoning" {
  name                 = var.gpt_reasoning_deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = var.gpt_reasoning_model_name
    version = var.gpt_reasoning_model_version
  }

  sku {
    name = var.deployment_scale_type
  }
}

# Azure OpenAI Deployment for Embeddings
# Note: Ensure you have sufficient quota for embeddings deployments in this Azure OpenAI resource.
resource "azurerm_cognitive_deployment" "embeddings" {
  name                 = var.embeddings_deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = var.embeddings_model_name
    version = var.embeddings_model_version
  }

  sku {
    name = var.deployment_scale_type
  }
}
