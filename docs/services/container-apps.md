# Azure Container Apps

Primary hosting platform for Django applications.

## Configuration

### Container App

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

Configure via Key Vault references where possible:

```
DATABASE_URL=secretref:kv-project-env/database-url
DJANGO_SECRET_KEY=secretref:kv-project-env/django-secret-key
```
