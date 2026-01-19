# Environment Configuration

Configuration differences between DEV, UAT, and PROD environments.

## Environment Summary

| Aspect              | DEV           | UAT           | PROD              |
|---------------------|---------------|---------------|-------------------|
| **Hosted By**       | Brightbeam    | Customer      | Customer          |
| **Purpose**         | Development   | Validation    | Production        |
| **Availability**    | Best effort   | Business hrs  | 24/7              |

## Compute Configuration

### Container Apps

| Setting        | DEV  | UAT  | PROD |
|----------------|------|------|------|
| Min Replicas   | 0    | 0    | 2    |
| Max Replicas   | 2    | 2    | 10   |
| CPU            | 0.5  | 0.5  | 1.0  |
| Memory         | 1Gi  | 1Gi  | 2Gi  |

### Container Apps Environment

| Setting          | DEV      | UAT      | PROD    |
|------------------|----------|----------|---------|
| Zone Redundancy  | Disabled | Disabled | Enabled |
| VNet Integration | Yes      | Yes      | Yes     |

## Database Configuration

### PostgreSQL Flexible Server

| Setting              | DEV            | UAT            | PROD                  |
|----------------------|----------------|----------------|----------------------|
| Compute Tier         | Burstable B1ms | Burstable B2s  | General Purpose D2ds |
| Storage              | 32 GB          | 64 GB          | 128 GB               |
| High Availability    | Disabled       | Disabled       | Zone-redundant       |
| Backup Retention     | 7 days         | 7 days         | 35 days              |
| Geo-Redundant Backup | No             | No             | Yes                  |

## Network Configuration

| Service        | DEV              | UAT              | PROD                |
|----------------|------------------|------------------|---------------------|
| PostgreSQL     | Public (limited) | Private (VNet)   | Private (VNet)      |
| Key Vault      | Public           | Public           | Private Endpoint    |
| Storage        | Public           | Public           | Private Endpoint    |
| Azure OpenAI   | Public           | Public           | Private Endpoint    |

## Security Configuration

| Setting               | DEV      | UAT      | PROD    |
|-----------------------|----------|----------|---------|
| Private Endpoints     | No       | Optional | Yes     |
| Key Vault Purge Prot. | Disabled | Enabled  | Enabled |

## Cost Implications

| Environment | Estimated Monthly (EUR) |
|-------------|-------------------------|
| DEV         | €150–300                |
| UAT         | €200–400                |
| PROD        | €500–1500               |

> Use the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) for accurate estimates based on actual usage.

## Cost Optimisation Tips

**DEV/UAT:**
- Scale Container Apps to zero when idle
- Use Burstable database tier
- Skip private endpoints

**PROD:**
- Right-size based on actual load
- Consider reserved capacity for predictable workloads
- Monitor and alert on cost anomalies
