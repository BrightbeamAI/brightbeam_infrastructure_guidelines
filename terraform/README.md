# Azure Terraform Infrastructure

This directory contains the Terraform configuration for deploying a generic Azure infrastructure with AI services, containerized applications, and data platform components.

## Prerequisites

Before using Terraform to deploy to Azure, you need:

1. **Terraform** (v1.0+)
   ```bash
   # macOS
   brew install terraform
   ```

2. **Azure CLI** (required for authentication)
   ```bash
   # macOS
   brew install azure-cli
   ```

3. **Azure Authentication**
   ```bash
   # Login to Azure
   az login

   # Set subscription (if you have multiple)
   az account set --subscription "Your-Subscription-Name"

   # Verify authentication and get your subscription ID
   az account show

   # Get just the subscription ID (you'll need this for configuration)
   az account show --query id -o tsv
   ```

   **Important:** Copy your subscription ID from the output above. You'll need to add it to your environment's `terraform.tfvars` file.

4. **Azure Permissions**
   - Contributor or Owner role on the target subscription
   - Ability to create resource groups and resources

## Structure

```
terraform/
├── Makefile                     # Convenient make targets for common operations
├── main.tf                      # Root module orchestrating all infrastructure
├── variables.tf                 # Root-level variable definitions
├── outputs.tf                   # Root-level outputs
├── provider.tf                  # Azure provider configuration
├── terraform.tfvars.example     # Example variables file
├── main.tf.backup               # Backup of original monolithic file
├── environments/
│   ├── uat/
│   │   ├── terraform.tfvars         # UAT configuration
│   │   ├── backend.conf             # UAT backend config (git-ignored)
│   │   └── backend.conf.example     # Backend template
│   └── prod/
│       ├── terraform.tfvars         # Production configuration
│       ├── backend.conf             # Prod backend config (git-ignored)
│       └── backend.conf.example     # Backend template
└── modules/
    ├── networking/             # VNet, subnets with delegations
    ├── observability/          # Log Analytics, Application Insights
    ├── storage/                # Storage accounts and blob containers
    ├── container_registry/     # Azure Container Registry
    ├── data_platform/          # PostgreSQL + Service Bus
    ├── ai_services/            # Azure OpenAI + deployments
    ├── security/               # Key Vault, managed identities, secrets
    └── compute/                # Container Apps + Function Apps
```

## Module Organization

### 1. **networking**
- Virtual Network (10.0.0.0/16)
- 4 Subnets with delegations:
  - Container Apps (10.0.0.0/23)
  - Functions (10.0.2.0/24)
  - PostgreSQL (10.0.3.0/24)
  - Private Endpoints (10.0.4.0/24)

### 2. **observability**
- Log Analytics Workspace
- Application Insights

### 3. **storage**
- Main storage account with CORS
- Blob containers (static-ui, images)
- Function app storage account

### 4. **container_registry**
- Azure Container Registry
- Network rules (Premium SKU only)

### 5. **data_platform**
- PostgreSQL Flexible Server with pgvector
- PostgreSQL database
- Service Bus namespace + queue

### 6. **ai_services**
- Azure OpenAI Cognitive Account
- GPT-4 deployment
- Text embedding deployment

### 7. **security**
- Key Vault with network rules
- Managed identities (container app, function app)
- Access policies
- Secret storage

### 8. **compute**
- Container Apps Environment
- Container App (Django app)
- App Service Plan
- Function App (data processor)

## Usage

### Quick Start with Makefile (Recommended)

The Makefile provides convenient commands that handle formatting, initialization, and validation automatically.

```bash
# 1. Get your Azure subscription ID
az account show --query id -o tsv

# 2. Configure subscription ID in environment tfvars file
# Edit environments/uat/terraform.tfvars and set the subscription_id variable
# Example: subscription_id = "f60dac04-0e57-4d28-a704-6e0999142c42"

# 3. Setup backend configuration (one-time per environment)
cp environments/uat/backend.conf.example environments/uat/backend.conf
# Edit backend.conf with your Azure storage account details

# 4. Plan deployment for UAT
make tf-plan env=uat

# Apply deployment for UAT
make tf-apply env=uat

# Deploy to production
make tf-plan env=prod
make tf-apply env=prod

# Destroy environment (careful!)
make tf-destroy env=uat

# Clean Terraform cache
make clean
```

**What the Makefile does:**
- Automatically runs `terraform fmt -recursive` (formats code)
- Runs `terraform init` with correct backend config
- Runs `terraform validate` (checks for errors)
- Executes the requested operation (plan/apply/destroy)

### Initial Backend Setup

Before using Terraform with remote state, you need to create the Azure Storage Account for storing Terraform state.

#### Option 1: Use the Bootstrap Project (Recommended)

The `bootstrap/` directory contains a self-contained Terraform project to create the backend storage:

```bash
# Navigate to bootstrap
cd bootstrap

# Review the plan
make tf-plan env=uat

# Create the storage account
make tf-apply env=uat

# Return to main terraform directory
cd ..
```

The bootstrap project creates environment-specific state storage:
- Resource Group: `rg-{project_name}-terraform-state-{environment}`
- Storage Account: `{project_name}tfstate{environment}` (must be globally unique)
- Blob Container: `tfstate`

See `bootstrap/README.md` for detailed setup instructions.

#### Option 2: Manual Creation (Alternative)

```bash
# Create resource group for state storage (example for UAT)
az group create --name rg-{project_name}-terraform-state-uat --location northeurope

# Create storage account (name must be globally unique)
az storage account create \
  --name {project_name}tfstateuat \
  --resource-group rg-{project_name}-terraform-state-uat \
  --location northeurope \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name {project_name}tfstateuat
```

#### Configure Backend

After creating the storage account (via bootstrap or manually):

1. **Copy backend template:**
```bash
cp environments/uat/backend.conf.example environments/uat/backend.conf
```

2. **Edit backend.conf** with values from bootstrap output:
```hcl
resource_group_name  = "rg-{project_name}-terraform-state-uat"
storage_account_name = "{project_name}tfstateuat"
container_name       = "tfstate"
key                  = "{project_name}-uat.tfstate"
```

3. **Repeat for production environment** with prod-specific values

## Environment Configurations

### UAT (`environments/uat/terraform.tfvars`)
- **Mid-tier resources**: GP_Standard_D2s_v3 (Postgres), EP1 (Functions)
- **Moderate scale**: 1-5 container app replicas
- **60-day log retention**
- **Standard ACR**
- **State file**: `{project_name}-{environment}.tfstate`

### Production (`environments/prod/terraform.tfvars`)
- **High-performance**: GP_Standard_D4s_v3 (Postgres), EP2 (Functions)
- **High availability**: 2-20 container app replicas (min 2)
- **Geo-redundant storage**: GRS replication
- **90-day log retention**
- **Premium Service Bus and ACR**
- **Purge protection enabled**
- **State file**: `{project_name}-{environment}.tfstate`

## Key Configuration Variables

### Required Variables
- `project_name` - Project identifier for resource naming
- `environment` - Environment name (uat/prod)
- `key_vault_allowed_ip_addresses` - Public IPs allowed to access Key Vault (rejects private IPs)

### Network Security

- `key_vault_allowed_ip_addresses` - Public IPs for Key Vault access (rejects 10.x, 172.16-31.x, 192.168.x)
- `acr_allowed_ip_addresses` - IPs for Container Registry (Premium SKU only)
- `openai_allowed_ip_addresses` - IPs for Azure OpenAI access

### Commonly Changed Variables
- `postgres_sku_name` - Database performance tier
- `postgres_storage_mb` - Database storage size
- `container_app_cpu` / `container_app_memory` - App resources
- `container_app_min_replicas` / `container_app_max_replicas` - Scaling limits
- `function_app_sku_name` - Function app tier (Y1, EP1, EP2)
- `log_retention_days` - Log retention period

### Brightbeam Image Copy Service Principal
- `create_image_copy_service_principal` - Enable/disable Brightbeam image-copy SP (default: false)
- `image_copy_sp_password_expiry_days` - Password expiry in days (default: 180)

### Networking Variables
- `vnet_address_space` - VNet CIDR (default: 10.0.0.0/16)
- `subnet_prefixes` - Subnet CIDRs for each service

## Outputs

Key outputs after deployment:

- `container_app_url` - Main application URL
- `postgres_fqdn` - Database connection endpoint
- `openai_endpoint` - Azure OpenAI endpoint
- `key_vault_name` - Key Vault name for secrets
- `container_registry_login_server` - ACR server for pushing images

View outputs:
```bash
terraform output
terraform output container_app_url
```

## Resource Naming Convention

Resources follow Azure naming conventions:
- Resource Group: `rg-{project_name}-{environment}`
- VNet: `vnet-{project_name}-{environment}`
- PostgreSQL: `psql-{project_name}-{environment}`
- Key Vault: `kv-{project_name}-{environment}`
- Container App: `ca-{app_name}-{environment}`
- Function App: `func-{app_name}-{environment}`

## Cost Management

### Cost by Environment (Approximate Monthly)

**UAT**: ~$500-800/month
- Standard tiers
- Moderate capacity

**Production**: ~$1500-3000/month
- Premium tiers
- High availability
- Geo-redundancy

### Cost Optimization Tips

1. **UAT**: Use `storage_replication_type = "LRS"` instead of GRS to reduce costs
2. **All environments**: Adjust `postgres_sku_name` based on actual workload
3. **All environments**: Use shorter `log_retention_days` if compliance allows

## Secrets Management

All secrets are stored in Azure Key Vault:
- PostgreSQL password and connection string
- OpenAI API key and endpoint
- Service Bus connection string
- Container Registry credentials
- Brightbeam image-copy service principal credentials (if enabled)

Applications access secrets via managed identities (no credentials in code).

### Brightbeam Image Copy Service Principal

A dedicated service principal can be created per environment to allow Brightbeam's deployment workflow to push container images from their dev ACR to this environment's ACR.

**Configuration:**
- Enable per environment: `create_image_copy_service_principal = true` in environment tfvars
- Password expiry: `image_copy_sp_password_expiry_days = 180` (default: 180 days)

**Credentials Storage:**
- Client ID: Stored in Key Vault as `image-copy-client-id`
- Client Secret: Stored in Key Vault as `image-copy-client-secret`

**Permissions:**
- Scoped to `AcrPush` role only on this environment's Container Registry (least privilege)

**Rotation:**
- Update `image_copy_sp_password_expiry_days` and run `terraform apply` to rotate credentials
- New credentials are automatically stored in Key Vault
- Coordinate with Brightbeam to update their deployment workflow with new credentials

## Network Security

- **Key Vault**: Restricted to specified IPs and subnet IDs
- **Azure OpenAI**: Network-restricted access
- **Container Registry**: Premium SKU enables network rules
- **PostgreSQL**: Delegated subnet with private access

⚠️ **IMPORTANT**: Update `allowed_ip_addresses` in `.tfvars` files with your actual IPs.

## Dependencies

Module dependency order (enforced in `main.tf`):
1. Resource Group (root)
2. Networking, Observability, Storage (independent)
3. Container Registry (needs networking)
4. Data Platform, AI Services (need networking)
5. Security (needs outputs from data, AI, registry)
6. Compute (needs everything)

## Troubleshooting

### Validation Errors
```bash
terraform validate
```

### Plan Shows Unexpected Changes
```bash
# Check what changed
terraform plan -var-file=environments/uat/terraform.tfvars

# See detailed diff
terraform show
```

### State Locked
```bash
# Force unlock (use carefully)
terraform force-unlock <lock-id>
```

### Need to Target Specific Module
```bash
# Apply only networking changes
terraform apply -var-file=environments/uat/terraform.tfvars -target=module.networking
```

## Architecture

This project uses a modular architecture with clear separation of concerns:

**Key Features:**
- 8 focused, reusable modules
- Environment-specific configurations (UAT, Production)
- Remote state management with Azure Storage
- Automated dependency management
- All values configurable via variables

## Next Steps

1. **Configure IPs**: Update `key_vault_allowed_ip_addresses` in environment tfvars with your public office/VPN IPs
2. **Review variables**: Check `environments/uat/terraform.tfvars` and adjust for your needs
3. **Plan first**: Always run `terraform plan` before `apply`
4. **Deploy UAT**: Start with UAT environment to test
5. **Build images**: Push container images to ACR before deploying compute
6. **Configure DNS**: Set up custom domain for container app if needed

## Additional Resources

- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
