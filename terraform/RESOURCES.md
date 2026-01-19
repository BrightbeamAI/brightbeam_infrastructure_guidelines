# Azure Resources - Generic Infrastructure

## What Gets Created

This Terraform configuration creates a complete AI-powered application infrastructure on Azure.

## Resource List & Purpose

### Core Infrastructure
- **Resource Group** - Container for all resources
- **Virtual Network** - Private network (10.0.0.0/16) with 4 subnets for isolation
- **Log Analytics + Application Insights** - Monitoring, logging, performance tracking

### Data Layer
- **PostgreSQL Flexible Server** - Database with pgvector extension for AI embeddings
- **Service Bus + Queue** - Message queue for async data processing tasks
- **2 Storage Accounts** - One for app static files/images, one for function runtime

### AI Services
- **Azure OpenAI Account** - Hosts AI models
  - GPT-4 deployment - For conversational AI
  - Text embedding deployment - For semantic search/similarity

### Security
- **Key Vault** - Stores all secrets (DB passwords, API keys, connection strings)
- **2 Managed Identities** - Passwordless access for container app and function app
- **Access Policies** - Control who can read secrets

### Container Infrastructure
- **Container Registry (ACR)** - Stores Docker images
- **Container Apps Environment** - Managed Kubernetes environment
- **Container App** - Runs Django application with auto-scaling (1-10 replicas)

### Serverless Processing
- **App Service Plan** - Compute for function app
- **Function App** - Scheduled data processing (runs daily at 6 AM)

## Why Each Resource is Needed

| Resource | Why? |
|----------|------|
| PostgreSQL | Store application data + AI embeddings (pgvector) |
| Azure OpenAI | Provide GPT-4 and embeddings for AI features |
| Container App | Run web application with auto-scaling |
| Function App | Process data on schedule without blocking web app |
| Service Bus | Decouple web app from long-running tasks |
| Key Vault | Secure secret management without hardcoded credentials |
| Managed Identities | Apps access secrets without passwords |
| ACR | Private registry for custom Docker images |
| Storage | Host static UI files, images, function state |
| VNet + Subnets | Network isolation and security |
| Monitoring | Debug issues, track performance, view logs |

## Resource Dependencies

```
Resource Group
  ├─ Networking (VNet + Subnets)
  ├─ Observability (Logs + Insights)
  ├─ Storage (Blob Storage)
  ├─ Container Registry (ACR)
  ├─ Data Platform (PostgreSQL + Service Bus)
  ├─ AI Services (OpenAI)
  ├─ Security (Key Vault + Identities + Secrets)
  └─ Compute (Container App + Function App)
       └─ Depends on everything above
```

## Total Resource Count

**~25 Azure resources** created per environment:
- 1 Resource Group
- 1 VNet + 4 Subnets
- 2 Storage Accounts + 2 Blob Containers
- 1 Container Registry
- 1 PostgreSQL Server + 1 Database
- 1 Service Bus + 1 Queue
- 1 OpenAI Account + 2 Deployments
- 1 Key Vault + 7 Secrets + 3 Access Policies
- 2 Managed Identities
- 1 Container Apps Environment + 1 Container App
- 1 App Service Plan + 1 Function App
- 1 Log Analytics Workspace + 1 Application Insights

## What Each Component Does

**Web Layer**: Container App serves Django application to users
**AI Layer**: OpenAI processes user queries and generates embeddings
**Data Layer**: PostgreSQL stores data, Service Bus queues background tasks
**Processing Layer**: Function App handles scheduled/queued work
**Security Layer**: Key Vault + Identities ensure secure access
**Observability Layer**: Logs and metrics for troubleshooting

## Cost Summary

Costs scale by environment (SKU/size differences):
- **UAT**: ~$500-800/month (standard tiers, moderate capacity)
- **Production**: ~$1500-3000/month (premium tiers, HA, geo-redundant)

Largest cost drivers: PostgreSQL, Azure OpenAI, Container Apps

See [`README.md`](README.md#cost-management) for cost optimization tips.
