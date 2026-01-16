# Terraform Bootstrap - Remote State Setup

This project creates Azure Storage for Terraform remote state management.

**What it creates per environment:**
- Resource Group
- Storage Account (with blob versioning)
- Blob Container (private access)

**Note:** This uses a local backend and must be run before the main infrastructure.

## Structure

```
bootstrap/
├── environments/
│   ├── uat/
│   │   └── terraform.tfvars    # UAT state storage configuration
│   └── prod/
│       └── terraform.tfvars     # Production state storage configuration
├── main.tf
├── variables.tf
├── outputs.tf
└── Makefile
```

## Usage

```bash
cd terraform/bootstrap

# 1. Configure environment-specific variables
# Edit environments/uat/terraform.tfvars and set:
#   - subscription_id
#   - resource_group_name (e.g., "rg-{project_name}-terraform-state-uat")
#   - storage_account_name (must be globally unique, e.g., "{project_name}tfstateuat")

# 2. Initialize, plan, and apply for UAT
make tf-init
make tf-plan env=uat
make tf-apply env=uat

# 3. Capture outputs for backend.conf
terraform output -var-file environments/uat/terraform.tfvars
```

## Next Steps

After creating the state storage:

1. **Copy outputs to backend.conf:**
   ```bash
   cd ../environments/uat
   cp backend.conf.example backend.conf
   # Edit backend.conf with the values from terraform output
   ```

2. **Set the state file key** in `backend.conf`:
   ```hcl
   key = "{project_name}-uat.tfstate"  # For UAT
   key = "{project_name}-prod.tfstate" # For Production
   ```

3. **Initialize the main Terraform project:**
   ```bash
   terraform init -backend-config=backend.conf
   ```

4. **Repeat for production** environment with prod-specific values.

