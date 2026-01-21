# PostgreSQL Database

Azure PostgreSQL Flexible Server with pgvector extension for AI-powered applications.

## Overview

This infrastructure uses **Azure Database for PostgreSQL - Flexible Server**, Microsoft's fully managed PostgreSQL service optimized for cloud-native applications.

### Why PostgreSQL?

**PostgreSQL was chosen for:**
- Strong relational data model with ACID guarantees
- Native vector similarity search via pgvector (critical for AI embeddings)
- Mature ecosystem and widespread developer familiarity
- Cost-effective for this workload size

### pgvector Extension

**pgvector** is a PostgreSQL extension that adds vector similarity search capabilities, enabling:
- Storing AI model embeddings (e.g., from Azure OpenAI)
- Efficient semantic search and similarity matching
- Nearest neighbor queries for recommendation systems

**Automatically installed by Terraform** - no manual setup required.

## Configuration by Environment

| Setting | UAT | PROD | Notes |
|---------|-----|------|-------|
| **SKU** | GP_Standard_D2s_v3 | GP_Standard_D4s_v3 | GP = General Purpose |
| **vCPUs** | 2 | 4 | Virtual CPU cores |
| **RAM** | 8 GB | 16 GB | Memory |
| **Storage** | 32 GB | 64 GB | Can be increased on-demand |
| **IOPS** | 720 | 1440 | Input/output operations per second |
| **Backup Retention** | 7 days | 35 days | Automatic backups |
| **High Availability** | No | Recommended | Zone-redundant HA |
| **Monthly Cost** | ~$150-200 | ~$350-450 | Approximate, varies by region |

### Understanding SKU Names

**GP_Standard_D2s_v3** breaks down as:
- **GP** = General Purpose tier (balanced compute/memory)
- **Standard** = Standard tier (vs Burstable for dev/test)
- **D2s** = D-series with 2 vCPUs
- **v3** = 3rd generation Intel Xeon processors

### When to Scale Up

Scale to a larger SKU when you observe:
- Consistent CPU usage > 70%
- Memory usage > 80%
- Query response times degrading
- Connection pool exhaustion

**Scaling is online** (no downtime) but requires a brief pause in write operations.

## Network Configuration

### Private-Only Access

**Important:** This PostgreSQL server has **no public endpoint**. It's only accessible from within the Azure Virtual Network.

**Security benefits:**
- No exposure to the internet
- Cannot be scanned or attacked from outside Azure
- Reduced attack surface

### VNet Integration

The database is deployed into a **delegated subnet**:

| Configuration | Value |
|---------------|-------|
| Subnet CIDR | 10.0.3.0/24 (256 IP addresses) |
| Subnet delegation | Microsoft.DBforPostgreSQL/flexibleServers |
| Private DNS zone | privatelink.postgres.database.azure.com |

**What is subnet delegation?**
Delegation allows Azure to manage network interfaces in this subnet on behalf of the PostgreSQL service. You cannot deploy other resources into a delegated subnet.

### How Applications Connect

1. **Container App** and **Function App** run in their own subnets (10.0.0.0/23 and 10.0.2.0/24)
2. They communicate with PostgreSQL via **VNet peering** (internal Azure network)
3. DNS resolution uses the private DNS zone to resolve the database hostname to its private IP
4. No internet traffic - all communication stays within Azure's backbone network

**Connection flow:**
```
Container App (10.0.0.x)
    → VNet internal routing
    → PostgreSQL subnet (10.0.3.x)
    → PostgreSQL server
```

## Connection Configuration

### Connection String Format

```
postgresql://username:password@hostname:5432/database_name?sslmode=require
```

**Example:**
```
postgresql://psqladmin:P@ssw0rd123@psql-my-project-uat.postgres.database.azure.com:5432/appdb?sslmode=require
```

### Connection Details

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Hostname (FQDN)** | `psql-{project}-{env}.postgres.database.azure.com` | Resolves to private IP via DNS |
| **Port** | `5432` | Standard PostgreSQL port |
| **Database name** | `appdb` (configurable) | Created automatically |
| **Admin username** | `psqladmin` (configurable) | Set in Terraform |
| **Admin password** | Auto-generated 32-char string | Stored in Key Vault |
| **SSL mode** | `require` | Always use SSL/TLS |

### Retrieving Connection Strings

**Connection strings are stored in Azure Key Vault** for security.

**From Container App or Function App:**

Applications retrieve the connection string at startup using their managed identity:

**From Azure CLI (for troubleshooting):**

```bash
# Get Key Vault name from Terraform outputs
KV_NAME=$(cd terraform && terraform output -raw key_vault_name)

# Retrieve connection string
az keyvault secret show --vault-name $KV_NAME --name postgres-connection-string --query value -o tsv
```

**From Terraform outputs:**

```bash
cd terraform
terraform output postgres_connection_string
```

## Authentication Options

### Option A: Basic Password Authentication (Current Implementation)

**How it works:**
- Admin username and password stored in Key Vault
- Applications retrieve credentials at startup
- Password auto-generated during Terraform deployment (32 characters, high entropy)

**Password rotation:**
- Recommended every 90 days for production
- Manual process: Update password in Azure Portal → Update Key Vault secret → Restart applications


### Option B: Azure AD Authentication (Recommended for Production)

**How it works:**
- PostgreSQL server configured to accept Azure AD tokens instead of passwords
- Managed identities used for application authentication
- No password storage required

**Benefits:**
- ✅ No passwords to manage or rotate
- ✅ Automatic token rotation by Azure
- ✅ Unified identity management
- ✅ Audit logs for database access

**Migration path** (future enhancement):
1. Enable Azure AD authentication on PostgreSQL server
2. Add managed identity as PostgreSQL user with appropriate permissions
3. Update application connection code to use Azure AD token
4. Retire password-based authentication

**Not currently implemented** - requires additional Terraform configuration and application code changes.

## pgvector Extension

### What is pgvector?

pgvector enables storing and querying vector embeddings in PostgreSQL, critical for:
- Semantic search (find similar documents)
- Recommendation engines
- AI-powered features
- RAG (Retrieval-Augmented Generation) systems

### Installation Status

✅ **Automatically installed** by Terraform during database provisioning.

No manual installation required.

## Backup and Recovery

### Automatic Backups

| Feature | UAT | PROD |
|---------|-----|------|
| Backup frequency | Daily | Daily |
| Retention period | 7 days | 35 days |
| Backup window | Automated | Automated |
| Geo-redundant backups | No | Recommended |

**Backups are automatic** - no manual intervention required.

### Point-in-Time Restore (PITR)

You can restore the database to any point in time within the retention period:

**Example:** Restore to 2 hours ago to recover from accidental data deletion.

**How to restore (Azure Portal):**
1. Navigate to your PostgreSQL server
2. Click "Overview" → "Restore"
3. Choose restore point (date/time)
4. Provide new server name (restores to a new server, doesn't overwrite existing)
5. Click "Review + create"

**How to restore (Azure CLI):**

```bash
az postgres flexible-server restore \
  --resource-group rg-my-project-uat \
  --name psql-my-project-uat-restored \
  --source-server psql-my-project-uat \
  --restore-time "2024-01-15T10:30:00Z"
```

**Important:**
- Restore creates a **new server** (original server remains unchanged)
- You'll need to update application connection strings to point to the restored server
- Restoring large databases can take 30-60 minutes


## Additional Resources

- [PostgreSQL Flexible Server Documentation](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/)
- [pgvector GitHub Repository](https://github.com/pgvector/pgvector)
- [PostgreSQL Performance Tuning](https://www.postgresql.org/docs/current/performance-tips.html)
- [Azure Database Best Practices](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-best-practices)
- [Main Troubleshooting Guide](../guides/troubleshooting.md)
