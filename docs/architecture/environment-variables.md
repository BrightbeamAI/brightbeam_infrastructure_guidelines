# Environment Variables Reference

Complete reference for environment variables available in Container Apps and Function Apps.

## Overview

Both Container Apps and Function Apps receive environment variables automatically via Terraform. Applications retrieve sensitive values from Key Vault at runtime using the Azure SDK.

## Common Environment Variables

These variables are available in **both** Container Apps and Function Apps:

### Managed Identity Configuration

| Variable | Value | Purpose |
|----------|-------|---------|
| `AZURE_KEY_VAULT_URL` | Key Vault URI | Base URL for Key Vault SDK operations |
| `AZURE_CLIENT_ID` | Managed identity client ID | Used by Azure SDK for authentication |

**Example values:**
```bash
AZURE_KEY_VAULT_URL=https://kv-project-uat.vault.azure.net/
AZURE_CLIENT_ID=12345678-1234-1234-1234-123456789abc
```

### Application Configuration

| Variable | Value | Purpose |
|----------|-------|---------|
| `STORAGE_ACCOUNT_NAME` | Storage account name | Direct reference to Azure Storage |
| `POSTGRES_CONNECTION_STRING_SECRET` | `"postgres-connection-string"` | Name of Key Vault secret containing PostgreSQL connection string |

**Example values:**
```bash
STORAGE_ACCOUNT_NAME=stprojectuat
POSTGRES_CONNECTION_STRING_SECRET=postgres-connection-string
```

## Function Apps Only

These variables are **only** available in Function Apps:

### Azure Functions Runtime

| Variable | Value | Purpose |
|----------|-------|---------|
| `FUNCTIONS_WORKER_RUNTIME` | `"python"` | Specifies Python runtime for Functions |
| `WEBSITES_ENABLE_APP_SERVICE_STORAGE` | `"false"` | Disable built-in storage (use container) |
| `AzureWebJobsStorage__accountName` | Storage account name | Internal Functions storage for state/bindings |

### Optional Timer Trigger

| Variable | Value | Purpose |
|----------|-------|---------|
| `SCHEDULE_EXPRESSION` | CRON expression | Timer trigger schedule (only if configured) |

**Example:**
```bash
SCHEDULE_EXPRESSION=0 0 * * * *  # Every hour
```

## Related Documentation

- [Container Apps Environment Variables](../services/container-apps.md#environment-variables)
- [Function Apps Environment Variables](../services/function-apps.md#environment-variables)
- [Key Vault Secrets](../services/key-vault.md#standard-secrets)
- [Azure OpenAI Configuration](../services/openai.md#api-configuration)
