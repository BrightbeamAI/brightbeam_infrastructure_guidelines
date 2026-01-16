# Troubleshooting

Common issues and solutions.

## Container Apps

| Symptom                       | Possible Cause                | Solution                              |
|-------------------------------|-------------------------------|---------------------------------------|
| App won't start               | Missing secrets               | Check Key Vault access and secret names|
| 502 Bad Gateway               | App crashed or not ready      | Check container logs in Log Analytics |
| Slow cold starts              | Scale-to-zero enabled         | Set min replicas > 0                  |
| Image pull failed             | ACR permissions               | Verify AcrPull role on Managed Identity|

**View logs:**
Azure Portal → Container App → Monitoring → Log stream

## PostgreSQL

| Symptom                       | Possible Cause                | Solution                              |
|-------------------------------|-------------------------------|---------------------------------------|
| Connection refused            | Firewall rules                | Add client IP or VNet rule            |
| SSL required error            | Missing sslmode               | Add `?sslmode=require` to connection  |
| Permission denied             | Wrong user/database           | Verify credentials in Key Vault       |
| Extension not found           | pgvector not enabled          | Run `CREATE EXTENSION vector;`        |

## Azure OpenAI

| Symptom                       | Possible Cause                | Solution                              |
|-------------------------------|-------------------------------|---------------------------------------|
| 401 Unauthorized              | Invalid credentials           | Check API key or Managed Identity role|
| 429 Too Many Requests         | Quota exceeded                | Reduce request rate or increase TPM   |
| Model not found               | Wrong deployment name         | Verify deployment name in portal      |
| Region not available          | OpenAI not in region          | Use Sweden Central or supported region|

## Key Vault

| Symptom                       | Possible Cause                | Solution                              |
|-------------------------------|-------------------------------|---------------------------------------|
| Access denied                 | Missing RBAC role             | Add Key Vault Secrets User role       |
| Secret not found              | Typo in secret name           | Check exact name in Key Vault         |
| Network error                 | Private endpoint config       | Verify VNet routing                   |

## Authentication

| Symptom                       | Possible Cause                | Solution                              |
|-------------------------------|-------------------------------|---------------------------------------|
| Redirect URI mismatch         | Wrong callback URL            | Update App Registration redirect URI  |
| User not authorized           | Tenant mismatch               | Verify single-tenant configuration    |
| Token expired                 | Session timeout               | Re-authenticate                       |

## Getting Help

1. Check container/function logs in Log Analytics
2. Review Azure Service Health for outages
