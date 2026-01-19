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

| Secret Name           | Description              | Rotation   |
|-----------------------|--------------------------|------------|
| django-secret-key     | Django SECRET_KEY        | On demand  |
| database-url          | PostgreSQL connection    | 90 days*   |
| openai-endpoint       | Azure OpenAI URL         | Static     |
| openai-key            | Azure OpenAI API key     | 90 days    |

> *Not required if using Azure AD authentication for PostgreSQL.

## Access Model

Use Azure RBAC (not Access Policies):

| Role                   | Principal              | Purpose            |
|------------------------|------------------------|--------------------|
| Key Vault Secrets User | Container App MI       | Read secrets       |
| Key Vault Administrator| DevOps Service Principal| Manage secrets    |

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
