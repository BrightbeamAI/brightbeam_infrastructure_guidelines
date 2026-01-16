# Azure Service Catalog

Configuration specifications for standard Brightbeam deployments.

## Core Services

| Service                              | Purpose                    | Documentation                    |
|--------------------------------------|----------------------------|----------------------------------|
| [Container Apps](container-apps.md)  | Application hosting        | Compute, scaling, ingress        |
| [PostgreSQL](postgresql.md)          | Primary database           | Tiers, HA, extensions            |
| [Azure OpenAI](openai.md)            | AI capabilities            | Models, quotas, deployment       |
| [Key Vault](key-vault.md)            | Secrets management         | Access, rotation                 |
| [Storage](storage.md)                | Files and uploads          | Containers, access tiers         |
| [Monitoring](monitoring.md)          | Observability              | Logs, metrics, alerts            |

## Optional Services

| Service       | When Used                           |
|---------------|-------------------------------------|
| Function Apps | Automated data ingestion            |
| Event Grid    | Event-driven architectures          |

## Service Dependencies

```
Container App
    ├── Key Vault (secrets)
    ├── PostgreSQL (data)
    ├── Azure OpenAI (AI)
    ├── Storage (files)
    └── App Insights (monitoring)
```