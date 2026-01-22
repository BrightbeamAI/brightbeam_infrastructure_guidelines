# Azure Function Apps

Background processing and scheduled tasks using containerized Python functions.

## Configuration

| Setting      | DEV  | UAT  | PROD | Notes                    |
|--------------|------|------|------|--------------------------|
| SKU          | EP1  | EP1  | EP2  | Elastic Premium plan     |
| Max Burst    | 10   | 10   | 20   | Maximum instances        |
| VNet Integration | Yes | Yes | Yes | Private network access  |

## Runtime

| Setting          | Value        |
|------------------|--------------|
| OS               | Linux        |
| Runtime          | Python       |
| Deployment       | Container    |
| Registry         | Azure ACR    |

## Managed Identity

Enable user-assigned managed identity for passwordless access to:
- Key Vault
- Storage Account (internal Functions storage)
- Container Registry

## Required RBAC Roles

| Role                             | Resource         | Purpose                          |
|----------------------------------|------------------|----------------------------------|
| Storage Blob Data Owner          | Functions Storage| Internal Functions storage       |
| Key Vault Secrets User           | Key Vault        | Secret retrieval                 |
| AcrPull                          | Container Registry | Pull container images          |

## Environment Variables

The following environment variables are automatically configured when running our terraform scripts:

### Azure Functions Runtime (Required)
```bash
FUNCTIONS_WORKER_RUNTIME            # "python" - Azure Functions runtime
WEBSITES_ENABLE_APP_SERVICE_STORAGE # "false" - Use container filesystem
AzureWebJobsStorage__accountName    # Storage account for Functions internals
```

### Managed Identity Configuration
```bash
AZURE_KEY_VAULT_URL          # Key Vault URI for SDK-based secret retrieval
AZURE_CLIENT_ID              # User-assigned managed identity client ID
```

### Application Configuration
```bash
STORAGE_ACCOUNT_NAME                 # Main storage account name
POSTGRES_CONNECTION_STRING_SECRET    # Key Vault secret name for PostgreSQL connection
SCHEDULE_EXPRESSION                  # CRON expression for timer triggers (optional)
```

### Secrets

See [Key Vault documentation](key-vault.md) for the complete list of available secrets.

## Timer Triggers

Function Apps support scheduled execution via timer triggers:

### CRON Expression Format

```
{second} {minute} {hour} {day} {month} {day-of-week}
```

**Examples:**
- `0 */5 * * * *` - Every 5 minutes
- `0 0 * * * *` - Every hour
- `0 0 0 * * *` - Daily at midnight UTC
- `0 0 9 * * MON-FRI` - Weekdays at 9 AM UTC

The `SCHEDULE_EXPRESSION` environment variable is automatically configured from the Terraform variable `function_app_schedule_expression`.

## VNet Integration

Function Apps are deployed with VNet integration on the Elastic Premium plan (EP1/EP2):

| Configuration | Value |
|---------------|-------|
| Subnet CIDR | 10.0.2.0/24 (256 IP addresses) |
| Outbound traffic | Routes through VNet |
| Access to | PostgreSQL, Key Vault, Storage via private network |

**Note:** Consumption plan (Y1) does not support VNet integration. This infrastructure uses Elastic Premium for secure private networking.

## Container Deployment

Function Apps run as Docker containers pulled from Azure Container Registry:

```bash
# Custom image (when configured)
{registry}.azurecr.io/{image-name}:{tag}
```

Container images are pulled using the Function App's managed identity (no username/password required).

## Additional Resources

- [Azure Functions Documentation](https://learn.microsoft.com/en-us/azure/azure-functions/)
- [Elastic Premium Plan](https://learn.microsoft.com/en-us/azure/azure-functions/functions-premium-plan)
- [Timer Triggers](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-timer)
- [Container Apps vs Function Apps](https://learn.microsoft.com/en-us/azure/container-apps/compare-options)
