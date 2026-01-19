# Architecture Overview

Standard architecture patterns for Brightbeam Azure deployments.

## Standard Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Azure Subscription                           │
│                                                                      │
│  ┌──────────┐     ┌─────────────────────────────────────────────┐   │
│  │  Users   │────▶│          Container App (Django)              │   │
│  └──────────┘     └──────────────────┬──────────────────────────┘   │
│       │                              │                               │
│       │                    ┌─────────┴─────────┐                    │
│       ▼                    ▼                   ▼                    │
│  ┌──────────┐     ┌──────────────┐    ┌──────────────┐             │
│  │ Entra ID │     │  PostgreSQL  │    │ Azure OpenAI │             │
│  │  (Auth)  │     │              │    │              │             │
│  └──────────┘     └──────────────┘    └──────────────┘             │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │  Key Vault   │  │   Storage    │  │  App Insights │              │
│  │  (Secrets)   │  │  (Files)     │  │  (Monitoring) │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
└─────────────────────────────────────────────────────────────────────┘
```

## Core Services

| Service                | Purpose                          |
|------------------------|----------------------------------|
| Container Apps         | Django application hosting       |
| PostgreSQL Flexible    | Primary database (with pgvector) |
| Azure OpenAI           | AI/LLM capabilities              |
| Key Vault              | Secrets management               |
| Storage Account        | Static files and uploads         |
| Application Insights   | Performance monitoring           |
| Entra ID               | User authentication (SSO)        |

## Architecture Pattern

Django application with AI features. Most common pattern.

**Services:** Container App, PostgreSQL (with pgVector extension), Azure OpenAI, Key Vault, Storage, App Insights, Blob Storage


## Cross-Tenant Model

**Brightbeam Tenant**
- DEV Environment
  - Container Registry (build & test)

**Customer Tenant**
- UAT Environment
  - Container Registry (receives images from Brightbeam DEV)
- PROD Environment
  - Container Registry (receives images from customer's UAT)

**Flow:**
1. Brightbeam builds and tests images in DEV
2. Images are promoted to customer registries for UAT/PROD
3. Customer controls their own deployments

## Related Documentation

- [Environment Configuration](environments.md)
- [Security Architecture](security.md)
- [Networking](networking.md)
