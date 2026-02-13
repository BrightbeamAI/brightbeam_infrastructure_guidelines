# Getting Started Guide

This guide will walk you through deploying Brightbeam infrastructure on Microsoft Azure from scratch. If you're new to Azure or infrastructure deployment, follow these steps carefully.

## 1. Prerequisites

Before you begin, ensure you have the following:

### Azure Subscription

You need an active Microsoft Azure subscription. A subscription is like an "account" that holds all your Azure resources and handles billing.

**Required Permissions:**
You need either **Contributor** or **Owner** role on the subscription. These roles allow you to:
- Create and modify resources
- Assign permissions to applications
- Manage costs and billing

To check your permissions:
1. Log into [Azure Portal](https://portal.azure.com)
2. Navigate to "Subscriptions"
3. Click on your subscription
4. Click "Access control (IAM)" → "View my access"

### Tools Installation

#### Azure CLI

The Azure Command-Line Interface (CLI) lets you manage Azure resources from your terminal.

**macOS:**
```bash
brew install azure-cli
```

**Windows (PowerShell as Administrator):**
```powershell
# Using Chocolatey
choco install azure-cli

# Or using winget
winget install Microsoft.AzureCLI
```

**Linux:**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**Verify installation:**
```bash
az --version
```

You should see version 2.0 or higher.

#### Terraform

Terraform is an infrastructure-as-code tool that will create your Azure resources automatically.

**macOS:**
```bash
brew install terraform
```

**Windows:**
```powershell
# Using Chocolatey
choco install terraform

# Or using Scoop
scoop install terraform
```

**Linux:**
```bash
# Download from https://www.terraform.io/downloads
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Verify installation:**
```bash
terraform --version
```

You should see version 1.0 or higher.

#### Git

Git is needed to clone this repository.

**macOS:**
```bash
# Git usually comes pre-installed, but you can update it:
brew install git
```

**Windows:**
Download from https://git-scm.com/download/win

**Linux:**
```bash
sudo apt install git  # Ubuntu/Debian
sudo yum install git  # CentOS/RHEL
```

**Verify installation:**
```bash
git --version
```

### Your Public IP Address

Azure Key Vault requires a public IP address for access control. This is YOUR internet-facing IP address (not your computer's local IP like 192.168.x.x).

**Find your public IP:**

**Option 1 - Web browser:**
Visit https://whatismyipaddress.com/ or https://ifconfig.me/

**Option 2 - Command line:**
```bash
curl ifconfig.me
```

**Important:** Write down this IP address - you'll need it in the configuration steps.

## 2. Initial Azure Setup

### Step 1: Login to Azure

Open your terminal and run:

```bash
az login
```

This will open your web browser for authentication. Sign in with your Azure account credentials.

### Step 2: Verify Your Subscription

After logging in, verify you're using the correct subscription:

```bash
az account show
```

This will display your current subscription details including:
- Subscription name
- Subscription ID (a long UUID like `f60dac04-0e57-4d28-a704-6e0999142c42`)
- Tenant ID

**If you have multiple subscriptions**, list them all:

```bash
az account list --output table
```

**Switch to the correct subscription:**

```bash
az account set --subscription "Your-Subscription-Name"
```

### Step 3: Get Your Subscription ID

You'll need your Subscription ID for the Terraform configuration:

```bash
az account show --query id -o tsv
```

**Copy this ID** - you'll use it in Step 4 (Configuration Steps).

### Understanding Azure Resource Groups

A **Resource Group** is a logical container for related Azure resources - think of it like a folder. All the infrastructure we'll create (databases, storage, applications) will live inside a resource group.

Terraform will automatically create the resource group for you, so you don't need to do anything manually.

## 3. Repository Setup

### Clone the Repository

Clone this infrastructure repository to your local machine:

```bash
git clone <repository-url>
cd brightbeam-infrastructure-guidelines
```

### Understanding the Directory Structure

```
.
├── terraform/                  # Infrastructure as code
│   ├── main.tf                # Main configuration file
│   ├── variables.tf           # Variable definitions
│   ├── environments/          # Environment-specific settings
│   │   ├── uat/              # User Acceptance Testing environment
│   │   └── prod/             # Production environment
│   └── modules/               # Reusable infrastructure components
├── docs/                       # Documentation
│   ├── architecture/          # Architecture patterns
│   ├── services/             # Service-specific docs
│   └── guides/               # Step-by-step guides (you are here!)
└── diagrams/                   # Architecture diagrams
```

### Choosing an Environment

This repository supports two customer-managed environments:

| Environment | Purpose | Resource Sizing | Cost |
|-------------|---------|----------------|------|
| **UAT** | User Acceptance Testing, pre-production validation | Mid-tier (D2 database, 1-5 app replicas) | ~$500-800/month |
| **PROD** | Production workload | High-performance (D4 database, 2-20 app replicas, geo-redundancy) | ~$1500-3000/month |

**Recommendation:** Start with **UAT** to test the deployment process before deploying production.

## 4. Configuration Steps

### Step 1: Navigate to Your Environment

For UAT:
```bash
cd terraform/environments/uat
```

For Production:
```bash
cd terraform/environments/prod
```

### Step 2: Edit terraform.tfvars

Open `terraform.tfvars` in your text editor:

```bash
# macOS/Linux
nano terraform.tfvars

# Or use your preferred editor
code terraform.tfvars  # VS Code
vim terraform.tfvars   # Vim
```

### Step 3: Update Required Variables

**1. Subscription ID** (from Step 2.3):
```hcl
subscription_id = "your-subscription-id-here"  # Replace with your actual ID
```

**2. Project Name:**
```hcl
project_name = "my-project"  # Change to your project identifier (lowercase, no spaces)
```

This name will be used to prefix all Azure resources. Example: `rg-my-project-uat`

**3. Key Vault IP Allowlist:**

Replace `"your-public-ip-here"` with your public IP address from Step 1 (Prerequisites):

```hcl
key_vault_allowed_ip_addresses = ["203.0.113.100"]  # Replace with YOUR public IP
```

**Why?** Azure Key Vault uses network security rules. By default, it blocks all traffic except from IP addresses you explicitly allow. This is a security feature.

**⚠️ Important:** This must be a PUBLIC IP address (like `203.0.113.100`). Azure Key Vault rejects private IP ranges like:
- 10.x.x.x
- 172.16.x.x - 172.31.x.x
- 192.168.x.x

**If you're on a corporate VPN or dynamic IP**, you may need to add multiple IP addresses or use a CIDR range like `"203.0.113.0/24"`.

### Step 4: Review Other Key Variables

You can leave these as defaults for now, but here's what they control:

```hcl
location = "northeurope"  # Azure region (North Europe data center)

# Database configuration
postgres_sku_name   = "GP_Standard_D2s_v3"  # General Purpose, 2 vCPUs, 8GB RAM
postgres_storage_mb = 32768                 # 32GB storage

# Container App scaling
container_app_min_replicas = 1  # Minimum app instances
container_app_max_replicas = 5  # Maximum app instances

# Additional features
create_image_copy_service_principal = true  # Enable Brightbeam deployment workflow
```

### Step 5: Save and Close

Save your changes and close the editor.

## 5. Backend State Storage Setup

Terraform needs a place to store its "state" - a record of what infrastructure it has created. This state is stored in an Azure Storage Account.

### What is Terraform State?

Think of Terraform state as a database that tracks:
- What resources have been created
- Their current configuration
- Relationships between resources

Without state, Terraform wouldn't know what infrastructure already exists.

### Option 1: Using the Bootstrap Project (Recommended)

The repository includes a `bootstrap/` directory with a pre-configured Terraform project to create the state storage account:

```bash
# Navigate to bootstrap directory (from repo root)
cd terraform/bootstrap
```

**Edit the bootstrap configuration:**

```bash
nano environments/uat/terraform.tfvars
```

Update:
- `subscription_id` (same as your main config)
- `project_name` (same as your main config)

**Create the state storage:**

```bash
# Plan (preview changes)
make tf-plan env=uat

# Apply (create resources)
make tf-apply env=uat
```

This creates:
- Resource Group: `rg-{project_name}-terraform-state-uat`
- Storage Account: `{project_name}tfstateuat` (globally unique name)
- Blob Container: `tfstate`

**Important:** Write down the storage account name - you'll need it next.

### Option 2: Manual Creation (Alternative)

If you prefer to create the storage account manually:

```bash
PROJECT_NAME="my-project"  # Use your project name
ENV="uat"                   # Or "prod"

# Create resource group
az group create \
  --name "rg-${PROJECT_NAME}-terraform-state-${ENV}" \
  --location northeurope

# Create storage account (name must be globally unique, 3-24 chars, lowercase letters and numbers only)
az storage account create \
  --name "${PROJECT_NAME}tfstate${ENV}" \
  --resource-group "rg-${PROJECT_NAME}-terraform-state-${ENV}" \
  --location northeurope \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name "${PROJECT_NAME}tfstate${ENV}"
```

### Configure Backend

Now tell Terraform where to store its state:

**1. Copy the template:**

```bash
# From terraform/environments/uat/ directory
cp backend.conf.example backend.conf
```

**2. Edit backend.conf:**

```bash
nano backend.conf
```

**3. Update with your values:**

```hcl
resource_group_name  = "rg-my-project-terraform-state-uat"
storage_account_name = "myprojecttfstateuat"
container_name       = "tfstate"
key                  = "my-project-uat.tfstate"
```

**Important:** Replace `my-project` with your actual project name.

**4. Save and close.**

## 6. First Deployment

You're now ready to deploy the infrastructure!

### Step 1: Navigate to Main Terraform Directory

```bash
# From repo root
cd terraform
```

### Step 2: Run Terraform Plan

This shows you what Terraform will create WITHOUT actually creating anything:

```bash
make tf-plan env=uat
```

**What happens:**
1. Terraform formats your code
2. Initializes providers and modules
3. Validates your configuration
4. Generates an execution plan

**Review the plan output.** You should see approximately 40-50 resources being created, including:
- Resource group
- Virtual network and subnets
- PostgreSQL database
- Storage accounts
- Container registry
- Container app
- Function app
- Key vault
- OpenAI service
- And more...

**Look for errors.** If you see any errors, review your configuration in Step 4.

### Step 3: Run Terraform Apply

If the plan looks good, apply it to create the infrastructure:

```bash
make tf-apply env=uat
```

**Terraform will ask for confirmation.** Type `yes` and press Enter.

**Expected deployment time:** 15-25 minutes

You'll see a stream of output as Terraform creates each resource. Don't interrupt this process.

### Step 4: Monitor Deployment Progress

You can watch progress in real-time:

**In your terminal:** Watch the Terraform output

**In Azure Portal:**
1. Log into https://portal.azure.com
2. Navigate to "Resource groups"
3. Find your resource group (e.g., `rg-my-project-uat`)
4. Click on it to see resources being created

### Step 5: Deployment Complete

When deployment finishes successfully, you'll see:

```
Apply complete! Resources: 45 added, 0 changed, 0 destroyed.

Outputs:

container_app_url = "https://ca-my-project-uat.northeurope.azurecontainerapps.io"
key_vault_name = "kv-my-project-uat"
postgres_fqdn = "psql-my-project-uat.postgres.database.azure.com"
...
```

**Congratulations!** Your infrastructure is now deployed.

## 7. Post-Deployment Verification

### Check Azure Portal

1. Log into https://portal.azure.com
2. Navigate to Resource groups → `rg-{your-project}-uat`
3. Verify these resources exist:
   - ✅ Virtual network (`vnet-{project}-uat`)
   - ✅ PostgreSQL server (`psql-{project}-uat`)
   - ✅ Container app (`ca-{project}-uat`)
   - ✅ Key vault (`kv-{project}-uat`)
   - ✅ Storage account (`st{project}uat`)
   - ✅ Container registry (`acr{project}uat`)
   - ✅ OpenAI service (`oai-{project}-uat`)

### Verify Container App URL

Get the URL from Terraform outputs:

```bash
terraform output container_app_url
```

**Try accessing it in your browser.** You should see a placeholder page or error (this is normal - no application container has been deployed yet).

### Test Key Vault Access

Verify you can access secrets:

```bash
# Get Key Vault name from outputs
KV_NAME=$(terraform output -raw key_vault_name)

# List secrets (should show postgres password, OpenAI key, etc.)
az keyvault secret list --vault-name $KV_NAME --output table
```

### Review All Outputs

See all the deployed resources' information:

```bash
terraform output
```

**Save these outputs** - you'll need them for application deployment and troubleshooting.

## Troubleshooting

### "Error: Unauthorized" during az login

**Cause:** Authentication failed or expired.

**Solution:**
```bash
az logout
az login
az account set --subscription "Your-Subscription-Name"
```

### "Error: storage account name is not available"

**Cause:** Storage account names must be globally unique across all of Azure.

**Solution:** Change your `project_name` in terraform.tfvars to something more unique, like adding your company name or random suffix.

### "Error: Key Vault ... not found or no permission"

**Cause:** Your IP address isn't allowed, or you don't have permissions.

**Solution:**
1. Verify your public IP hasn't changed: `curl ifconfig.me`
2. Update `key_vault_allowed_ip_addresses` in terraform.tfvars
3. Re-run `make tf-apply env=uat`

### "Error: Quota exceeded for OpenAI"

**Cause:** Azure OpenAI requires quota approval in some regions.

**Solution:** The terraform configuration uses Sweden Central region which has OpenAI capacity. If you still see this error, contact Azure support to request quota.

### Terraform plan shows unexpected changes

**Cause:** Your local configuration doesn't match the deployed state.

**Solution:**
```bash
# Refresh state from Azure
terraform refresh -var-file=environments/uat/terraform.tfvars

# View current state
terraform show
```

### Need More Help?

- **Terraform Errors:** See [Terraform Troubleshooting](troubleshooting.md)
- **Azure Issues:** Check [Azure Documentation](https://docs.microsoft.com/azure/)
- **Service-Specific Issues:** See service documentation in [docs/services/](../services/README.md)
