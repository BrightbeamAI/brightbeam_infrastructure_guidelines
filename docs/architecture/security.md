# Security Architecture

Authentication, authorisation, and secrets management patterns.

## Identity Model

| Account Type       | Purpose                    | Authentication        |
|--------------------|----------------------------|-----------------------|
| DevOps Pipeline    | CI/CD automation           | Service Principal     |
| Application        | Azure service access       | Managed Identity      |
| Cross-Tenant       | Image registry access      | Service Principal     |
| End Users          | Application access         | Entra ID (SSO)        |

## Service Principals

### DevOps Pipeline

One per environment, created by customer.

**Naming:** `sp-[project]-devops-[env]`

**Required Roles:**

| Role                    | Scope              |
|-------------------------|--------------------|
| AcrPush                 | Container Registry |
| Contributor             | Container Apps     |
| Key Vault Secrets User  | Key Vault          |

**Credential Management:**
- Store in Azure DevOps Service Connections or GitHub Secrets
- Rotate every 90 days
- Never commit to source control

### Cross-Tenant (Registry Access)

Allows Brightbeam to push images to customer UAT registry.

**Created By:** Customer  
**Name:** `sp-brightbeam-acr-push`  
**Role:** AcrPush on UAT Container Registry  

Customer transfers credentials securely to Brightbeam and controls lifecycle.

## Managed Identity

Container Apps use system-assigned managed identity for passwordless access to Azure services.

**Required Role Assignments:**

| Service          | Role                              |
|------------------|-----------------------------------|
| Key Vault        | Key Vault Secrets User            |
| Storage          | Storage Blob Data Contributor     |
| Azure OpenAI     | Cognitive Services OpenAI User    |
| Container Reg.   | AcrPull                           |

## User Authentication

Users authenticate via Microsoft Entra ID (SSO).

**App Registration Settings:**

| Setting           | Value                                    |
|-------------------|------------------------------------------|
| Account Type      | Single tenant                            |
| Redirect URI      | `https://{app-url}/.auth/login/aad/callback` |
| Token Config      | ID tokens                                |
| API Permissions   | Microsoft Graph: User.Read               |

## Secrets Management

All secrets stored in Azure Key Vault.

**Standard Secrets:**

| Secret                | Rotation  |
|-----------------------|-----------|
| django-secret-key     | On demand |
| database-password*    | 90 days   |
| openai-key            | 90 days   |

> *Not required if using Azure AD authentication for PostgreSQL.

**Access Pattern:**
1. Container App authenticates via Managed Identity
2. Retrieves secrets at startup
3. Secrets cached in memory only

## Database Authentication

**Option A: Azure AD (Recommended)**
- Managed Identity as Azure AD Admin
- No password storage required
- Automatic token rotation

**Option B: PostgreSQL User**
- Dedicated application user
- Password in Key Vault
- 90-day rotation policy

## Security Checklist

- [ ] Separate service accounts per environment
- [ ] No credentials in source code or images
- [ ] All secrets in Key Vault
- [ ] Private endpoints enabled (PROD)
- [ ] TLS 1.2+ for all connections
- [ ] Audit logging enabled
