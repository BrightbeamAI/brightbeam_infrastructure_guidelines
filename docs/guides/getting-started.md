# Getting Started

Steps to prepare your Azure environment for a Brightbeam deployment.

## Prerequisites

- [ ] Azure subscription with Owner or Contributor role
- [ ] Microsoft Entra ID admin access (for App Registration)
- [ ] Azure CLI installed (`az --version`)

## Step 1: Create Resource Group

Create a resource group for each environment (UAT, PROD).

**Naming:** `rg-[project]-[env]`

**Location:** Choose an EU region (e.g., North Europe, West Europe) for data residency.

## Step 2: Request Azure OpenAI Access

Azure OpenAI requires approval. Apply at: https://aka.ms/oai/access

Allow 1–5 business days for approval.

## Step 3: Create Service Principal for DevOps

Create a service principal for CI/CD deployments.

**Naming:** `sp-[project]-devops-[env]`

**Required Roles:**
- Contributor on Resource Group
- AcrPush on Container Registry
- Key Vault Secrets User on Key Vault

Store credentials securely (Azure DevOps Service Connection or GitHub Secrets).

## Step 4: Create App Registration

Create an App Registration for user authentication.

**Settings:**
- Single tenant
- Redirect URI: `https://{app-url}/.auth/login/aad/callback`
- API permissions: Microsoft Graph → User.Read

## Step 5: Coordinate with Brightbeam

Provide Brightbeam with:

| Item                       | Purpose                              |
|----------------------------|--------------------------------------|
| Subscription ID            | Target subscription                  |
| Resource Group name        | Deployment location                  |
| Service Principal creds    | For image push (UAT registry)        |
| App Registration details   | Client ID, Tenant ID                 |

## Next Steps

Once infrastructure is provisioned:
1. Brightbeam deploys application container
2. Configure DNS/custom domain (if required)
3. Validate application functionality
4. Complete UAT sign-off
5. Repeat for PROD environment

## Troubleshooting

| Issue                      | Solution                             |
|----------------------------|--------------------------------------|
| "Subscription not found"   | Check `az account set --subscription`|
| "Permission denied"        | Verify RBAC role assignments         |
| "Quota exceeded"           | Request quota increase in portal     |
| OpenAI not available       | Confirm region supports Azure OpenAI |
