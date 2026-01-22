# Azure Service Catalog

Configuration specifications for standard Brightbeam deployments.

## Core Services

| Service                              | Purpose                    | Documentation                    |
|--------------------------------------|----------------------------|----------------------------------|
| [Container Apps](container-apps.md)  | Application hosting        | Compute, scaling, ingress        |
| [Function Apps](function-apps.md)    | Background processing      | Scheduled tasks, timer triggers  |
| [PostgreSQL](postgresql.md)          | Primary database           | Tiers, HA, extensions            |
| [Azure OpenAI](openai.md)            | AI capabilities            | Models, quotas, deployment       |
| [Key Vault](key-vault.md)            | Secrets management         | Access, rotation                 |
| [Storage](storage.md)                | Files and uploads          | Containers, access tiers         |
| [Monitoring](monitoring.md)          | Observability              | Logs, metrics, alerts            |

## Optional Services

| Service       | When Used                           |
|---------------|-------------------------------------|
| Event Grid    | Event-driven architectures          |

## Service Dependencies

```
Container App / Function App
    ├── Key Vault (secrets)
    ├── PostgreSQL (data)
    ├── Azure OpenAI (AI)
    ├── Storage (files)
    └── App Insights (monitoring)
```

**Note:** Both Container Apps and Function Apps have identical access to backend services via managed identity and VNet integration.