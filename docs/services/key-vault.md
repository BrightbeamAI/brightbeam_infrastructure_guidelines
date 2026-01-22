# Azure Key Vault

Centralised secrets management.

## Configuration

| Setting              | DEV      | UAT     | PROD            |
|----------------------|----------|---------|-----------------|
| SKU                  | Standard | Standard| Standard        |
| Soft Delete          | Enabled  | Enabled | Enabled         |
| Purge Protection     | Disabled | Enabled | Enabled         |
| Public Network       | Allowed  | Allowed | Private Endpoint|

## Standard Secrets

The following secrets are automatically created by Terraform:

| Secret Name                  | Description                                      |
|------------------------------|--------------------------------------------------|
| postgres-connection-string   | PostgreSQL full connection string (includes embedded password) |
| openai-api-key               | Azure OpenAI API key                             |
| openai-endpoint              | Azure OpenAI endpoint URL                        |
| openai-deployment-name       | Azure OpenAI GPT model deployment name           |
| openai-api-version           | Azure OpenAI API version (e.g., 2024-02-15-preview) |
| embeddings-deployment-name   | Azure OpenAI embeddings model deployment name    |
| embeddings-api-version       | Azure OpenAI embeddings API version              |
| servicebus-connection-string | Service Bus namespace connection string          |
| acr-username                 | Container Registry admin username                |
| acr-password                 | Container Registry admin password                |
| image-copy-client-id         | Brightbeam image-copy service principal ID (optional) |
| image-copy-client-secret     | Brightbeam image-copy service principal secret (optional) |

**Note:** The `image-copy-*` secrets are only created if the `create_image_copy_service_principal` variable is enabled in Terraform.

## Access Model

This infrastructure uses **Access Policies** for Key Vault authentication:

| Access Policy          | Principal              | Permissions        |
|------------------------|------------------------|--------------------|
| Secret Permissions     | Container App Managed Identity | Get, List   |
| Secret Permissions     | Function App Managed Identity  | Get, List   |
| Secret Permissions     | Deployer (Terraform)   | Get, List, Set, Delete, Purge |

**Why Access Policies?**
- Simpler configuration for straightforward secret access scenarios
- Works well with managed identities
- Sufficient for most application needs

**Note:** Azure RBAC for Key Vault is an alternative model that provides more granular control and integrates with Azure's unified RBAC system. Consider migrating to RBAC if you need more complex permission scenarios.

## Secret References in Container Apps

Container Apps can reference Key Vault secrets directly:

```
secretref:kv-project-env/secret-name
```

This avoids hardcoding secrets in environment variables.

## Naming Convention

```
[service]-[purpose]
```

Examples: `database-url`, `django-secret-key`, `openai-key`
