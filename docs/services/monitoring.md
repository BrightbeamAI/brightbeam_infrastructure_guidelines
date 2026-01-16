# Monitoring

Azure Monitor, Log Analytics, and Application Insights.

## Log Analytics Workspace

One workspace per environment.

| Setting   | Value      |
|-----------|------------|
| Retention | 90 days    |
| SKU       | PerGB2018  |

## Application Insights

Connected to Log Analytics workspace.

**Key Metrics:**
- Request rate and response times
- Exception tracking
- Dependency performance (database, Azure OpenAI)
- Custom business events

**Django Integration:** Use `opencensus-ext-azure` SDK.

## Recommended Alerts

| Alert                     | Threshold          | Severity |
|---------------------------|--------------------|----------|
| HTTP 5xx errors           | > 5 in 5 minutes   | Warning  |
| Response time             | > 5s average       | Warning  |
| Container App restarts    | > 3 in 10 minutes  | Critical |
| Database CPU              | > 80% sustained    | Warning  |
| Failed authentication     | > 10 in 5 minutes  | Warning  |

## Diagnostic Settings

Enable diagnostic logs for:
- Container Apps (console logs, system logs)
- PostgreSQL (query logs, error logs)
- Key Vault (audit logs)

Route all logs to the Log Analytics workspace.

## Cost Considerations

Log ingestion is charged per GB. Consider:
- Filtering verbose debug logs in production
- Sampling for high-volume telemetry
- Setting appropriate retention periods
