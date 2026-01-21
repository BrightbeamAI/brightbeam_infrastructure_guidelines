# Brightbeam Lifesciences Infrastructure Guidelines

Infrastructure documentation and deployment guidelines for Brightbeam Lifesciences solutions on Microsoft Azure.

## Overview

This repository provides standard architecture patterns, service configurations, and deployment guidance for customer Azure environments. 

This is a high-level guide with generic suggestions. Each project may require modifications based on specific requirements.

We use terraform for our Infrastructure as Code. This repository contains an example terraform configuration that can be updated and used for establishing your infrastructure, based on what is required for your project.

## Repository Structure

```
docs/
├── architecture/       # Architecture patterns and environment setup
├── services/          # Azure service configurations
└── guides/            # Step-by-step deployment guides
terraform/             # Example Infrastructure as Code (should be updated with your own configuration for your project)
diagrams/              # Architecture diagrams
```

## Environments

| Environment | Hosted By   | Purpose                    |
|-------------|-------------|----------------------------|
| DEV         | Brightbeam  | Development and testing    |
| UAT         | Customer    | Pre-production validation  |
| PROD        | Customer    | Production workload        |

## For First-Time Users

If you're new to Azure or infrastructure deployment:
1. Start with the [Getting Started Guide](docs/guides/getting-started.md)
2. Review [Prerequisites](#prerequisites) below
3. Read [Architecture Overview](docs/architecture/overview.md) to understand what will be deployed

## Prerequisites

Before deploying this infrastructure, you need:
- Active Azure subscription
- Azure CLI installed and configured
- Terraform v1.0 or higher
- Contributor or Owner role on the subscription
- Your public IP address (for Key Vault access)

See the [Getting Started Guide](docs/guides/getting-started.md) for detailed setup instructions.

## Quick Links

- [Architecture Overview](docs/architecture/overview.md)
- [Environment Configuration](docs/architecture/environments.md)
- [Getting Started Guide](docs/guides/getting-started.md)
- [Service Catalog](docs/services/README.md)
- [Terraform](terraform/README.md)

## Naming Convention

All Azure resources follow this pattern:

```
[prefix]-[project]-[environment]
```

| Resource Type      | Prefix | Example                        |
|--------------------|--------|--------------------------------|
| Resource Group     | rg     | rg-acme-co-forecasting-prod    |
| Container App      | ca     | ca-acme-co-forecasting-prod    |
| PostgreSQL Server  | psql   | psql-acme-co-forecasting-prod  |
| Key Vault          | kv     | kv-acme-co-forecasting-prod    |
| Storage Account    | st     | stacmecoforecastingprod       |

> **Note:** Storage Accounts and Container Registries cannot contain hyphens.

