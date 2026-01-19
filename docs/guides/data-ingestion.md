# Data Ingestion

Patterns for uploading data into Brightbeam solutions.

## Options Overview

| Pattern          | Best For                        | Complexity |
|------------------|---------------------------------|------------|
| Web UI Upload    | Occasional manual uploads       | Low        |
| Blob Storage     | Automated file drops            | Medium     |
| SharePoint       | Microsoft 365 integration       | High       |

## Web UI Upload

Users upload files directly through the application.

```
User → Web UI → Validate → Process → Database
```

**Advantages:** Simple, immediate feedback, no additional services.

**Limitations:** Manual process, file size limits.

**When to use:** Weekly or less frequent uploads, files under 100MB.

## Blob Storage Upload

Files dropped into Azure Blob Storage trigger automatic processing.

```
User → Blob Storage → Function App → Process → Database
```

**Additional Services Required:**
- Storage Account (upload container)
- Function App (processing trigger)

**Advantages:** Automated, handles large files, supports scripted uploads.

**Limitations:** Delayed feedback, requires Azure storage access.

**When to use:** Daily automated uploads, large files, integration with data pipelines.

## SharePoint Integration

Files in SharePoint trigger processing via webhook.

```
User → SharePoint → Webhook → Function App → Graph API → Process → Database
```

**Additional Requirements:**
- Function App with HTTP trigger
- App Registration with Graph API permissions:
  - Sites.Read.All
  - Files.Read.All
- Webhook renewal logic (expires every 6 months)

**Advantages:** Native Microsoft 365 experience, leverages SharePoint permissions.

**Limitations:** Complex setup, webhook maintenance required.

**When to use:** Organisation heavily uses SharePoint, need SharePoint metadata.

## Choosing a Pattern

| If you need...                  | Use...          |
|---------------------------------|-----------------|
| Simplest setup                  | Web UI          |
| Automation                      | Blob Storage    |
| Microsoft 365 integration       | SharePoint      |
| Large file support              | Blob Storage    |
| Immediate feedback              | Web UI          |

Most projects start with Web UI and add automation later if needed.
