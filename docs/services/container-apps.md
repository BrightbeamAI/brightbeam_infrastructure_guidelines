# Azure Container Apps

Primary hosting platform for Django applications.

## Configuration

### Container App
Suggested configuration:

| Setting      | DEV  | UAT  | PROD | Notes                    |
|--------------|------|------|------|--------------------------|
| Min Replicas | 0    | 0    | 2    | PROD always-on for HA    |
| Max Replicas | 2    | 2    | 10   | Scale based on load      |
| CPU          | 0.5  | 0.5  | 1.0  | vCPU cores               |
| Memory       | 1Gi  | 1Gi  | 2Gi  | GiB                      |

### Container Apps Environment

| Setting          | DEV      | UAT      | PROD    |
|------------------|----------|----------|---------|
| Zone Redundancy  | Disabled | Disabled | Enabled |
| Workload Profile | Consumption | Consumption | Consumption |

## Ingress

| Setting        | Value        |
|----------------|--------------|
| External       | Yes          |
| Target Port    | 8000         |
| Transport      | HTTP/1.1     |
| Allow Insecure | No           |

## Managed Identity

Enable system-assigned managed identity for passwordless access to:
- Key Vault
- Storage Account
- Azure OpenAI
- Container Registry

## Required RBAC Roles

| Role                             | Resource         |
|----------------------------------|------------------|
| Key Vault Secrets User           | Key Vault        |
| Storage Blob Data Contributor    | Storage Account  |
| Cognitive Services OpenAI User   | Azure OpenAI     |
| AcrPull                          | Container Registry |

## Environment Variables

The following environment variables are automatically configured:

### Managed Identity Configuration
```bash
AZURE_KEY_VAULT_URL          # Key Vault URI for SDK-based secret retrieval
AZURE_CLIENT_ID              # User-assigned managed identity client ID
```

### Other Settings
```bash
STORAGE_ACCOUNT_NAME                 # Azure Storage account name
POSTGRES_CONNECTION_STRING_SECRET    # Key Vault secret name for PostgreSQL connection
```

### Secrets

See [Key Vault documentation](key-vault.md) for the complete list of available secrets.

## Differences from Function Apps

| Feature | Container Apps | Function Apps |
|---------|---------------|---------------|
| **Purpose** | Web applications, APIs | Background jobs, scheduled tasks |
| **Scaling** | HTTP-based autoscaling | Event-driven + timer-based |
| **Ingress** | External HTTPS endpoint | No public endpoint (event-driven) |
| **Runtime** | Any container | Azure Functions runtime required |
| **Storage** | Optional | Required (internal Functions state) |
| **Environment Variables** | Core vars only | Core vars + Functions-specific |

Both apps have identical access to:
- Key Vault secrets via managed identity
- PostgreSQL database
- Storage accounts
- Azure OpenAI

See [Function Apps documentation](function-apps.md) for details on scheduled tasks and background processing.
