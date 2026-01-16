# Production Environment - Terraform State Storage Configuration

# Azure subscription ID (get from: az account show --query id -o tsv)
subscription_id = "your-subscription-id-here"

# Azure region for state resources
location = "northeurope"

# Resource group for Terraform state
resource_group_name = "rg-{project_name}-terraform-state-prod"

# Globally unique storage account name (must be 3-24 lowercase alphanumerics)
# Example: {project_name}tfstateprod
storage_account_name = "{project_name}tfstateprod"

# Blob container for state files
container_name = "tfstate"

