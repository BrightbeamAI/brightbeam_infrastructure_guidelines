# Azure OpenAI Service

LLM capabilities for AI-powered features.

## Configuration

| Setting        | DEV           | UAT           | PROD             |
|----------------|---------------|---------------|------------------|
| Region         | Sweden Central| Sweden Central| Sweden Central   |
| Network Access | Public        | Public        | Private Endpoint |

## Standard Model Deployments

| Model                    | Deployment Name          | Purpose              |
|--------------------------|--------------------------|----------------------|
| gpt-5.1               | gpt-5.1                   | Primary reasoning    |
| gpt-5-mini          | gpt-5-mini              | High-volume tasks    |
| text-embedding-3-small   | text-embedding-3-small   | Embeddings (RAG)     |

> TPM = Tokens Per Minute. Quotas are subscription-level.

## Deployment Considerations

**Separate instances per subscription.** TPM quotas are shared across all deployments in a subscription. Deploy separate Azure OpenAI instances for DEV, UAT, and PROD to prevent quota conflicts.

## Access Configuration

Grant Container App's Managed Identity the `Cognitive Services OpenAI User` role.

## API Endpoint Format

```
https://{resource-name}.openai.azure.com/
```

## Rate Limiting

If quota is exceeded, requests return HTTP 429. Implement exponential backoff in application code.
