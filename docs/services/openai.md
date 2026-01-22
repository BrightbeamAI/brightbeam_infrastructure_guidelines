# Azure OpenAI Service

LLM capabilities for AI-powered features.

## Configuration

| Setting          | DEV                      | UAT                      | PROD                     |
|------------------|--------------------------|--------------------------|--------------------------|
| Deployment Type  | Data Zone Standard (EUR) | Data Zone Standard (EUR) | Data Zone Standard (EUR) |
| Network Access   | Public                   | Public                   | Private Endpoint         |

## Standard Model Deployments

| Model                    | Deployment Name          | Purpose              | Default Version |
|--------------------------|--------------------------|----------------------|-----------------|
| gpt-5.1               | gpt-5.1                   | Primary reasoning    | 2025-11-13      |
| gpt-5-mini          | gpt-5-mini              | High-volume tasks    | -               |
| text-embedding-3-small   | text-embedding-3-small   | Embeddings (RAG)     | 2               |

> TPM = Tokens Per Minute. Quotas are subscription-level.

## API Configuration

The following configuration values are stored in Key Vault and retrieved at runtime using the Azure SDK:

| Configuration          | Key Vault Secret           | Example Value                    |
|------------------------|---------------------------|----------------------------------|
| API Key                | openai-api-key            | (sensitive)                      |
| Endpoint               | openai-endpoint           | https://oai-project-env.openai.azure.com/ |
| Deployment Name        | openai-deployment-name    | gpt-5.1                          |
| API Version            | openai-api-version        | 2024-02-15-preview               |
| Embeddings Deployment  | embeddings-deployment-name| text-embedding-3-small           |
| Embeddings API Version | embeddings-api-version    | 2024-02-15-preview               |

## Deployment Considerations

**Data Zone Standard (EUR)** ensures all data processing (inputs, outputs, model inference) remains within the European Union data boundary for GDPR compliance. Traffic is dynamically routed to the data center with best availability within the EU zone.

**Separate instances per subscription.** TPM quotas are shared across all deployments in a subscription. Deploy separate Azure OpenAI instances for DEV, UAT, and PROD to prevent quota conflicts.

> **Note:** GPT-5 models are only available via Data Zone Standard deployments, not regional deployments.

## Access Configuration

Grant Container App's Managed Identity the `Cognitive Services OpenAI User` role.

## API Endpoint Format

```
https://{resource-name}.openai.azure.com/
```

## Rate Limiting

If quota is exceeded, requests return HTTP 429. Implement exponential backoff in application code.
