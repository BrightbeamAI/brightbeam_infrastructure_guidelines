# Networking

Virtual network configuration and private connectivity.

## VNet Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Virtual Network                           │
│                    10.0.0.0/16                               │
│                                                              │
│  ┌─────────────────────┐  ┌─────────────────────┐          │
│  │ snet-container-apps │  │ snet-postgres       │          │
│  │ 10.0.0.0/23         │  │ 10.0.3.0/24         │          │
│  │                     │  │                     │          │
│  │ Container Apps Env  │  │ PostgreSQL (deleg.) │          │
│  └─────────────────────┘  └─────────────────────┘          │
│                                                              │
│  ┌─────────────────────┐  ┌─────────────────────┐          │
│  │ snet-functions      │  │ snet-private-ep     │          │
│  │ 10.0.2.0/24         │  │ 10.0.4.0/24         │          │
│  │                     │  │                     │          │
│  │ Functions (if used) │  │ Private Endpoints   │          │
│  └─────────────────────┘  └─────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Subnet Configuration

| Subnet              | CIDR          | Purpose                 | Delegation                              |
|---------------------|---------------|-------------------------|-----------------------------------------|
| snet-container-apps | 10.0.0.0/23   | Container Apps          | Managed by Container Apps               |
| snet-functions      | 10.0.2.0/24   | Azure Functions         | Microsoft.Web/serverFarms               |
| snet-postgres       | 10.0.3.0/24   | PostgreSQL              | Microsoft.DBforPostgreSQL/flexibleServers |
| snet-private-ep     | 10.0.4.0/24   | Private Endpoints       | None                                    |

## Private Endpoints (Production)

May be used in production environments to ensure traffic stays on Azure backbone.

| Service      | Private DNS Zone                        |
|--------------|-----------------------------------------|
| PostgreSQL   | privatelink.postgres.database.azure.com |
| Key Vault    | privatelink.vaultcore.azure.net         |
| Storage      | privatelink.blob.core.windows.net       |
| Azure OpenAI | privatelink.openai.azure.com            |

## Network Access by Environment

| Service      | DEV            | UAT          | PROD            |
|--------------|----------------|--------------|-----------------|
| Container App| External HTTPS | External HTTPS| External HTTPS |
| PostgreSQL   | Public*        | VNet only    | Private Endpoint|
| Key Vault    | Public         | Public       | Private Endpoint|
| Storage      | Public         | Public       | Private Endpoint|
| Azure OpenAI | Public         | Public       | Private Endpoint|

> *DEV allows public access with IP allowlist for development convenience.

## Ingress Configuration

Container Apps use external ingress with HTTPS only.

| Setting        | Value           |
|----------------|-----------------|
| External       | Yes             |
| Target Port    | 8000            |
| Transport      | HTTP/1.1        |
| Allow Insecure | No              |

Custom domains require DNS CNAME and managed certificate configuration.
