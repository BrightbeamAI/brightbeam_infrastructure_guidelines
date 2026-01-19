# Azure Storage Account

Blob storage for static files and document uploads.

## Configuration

| Setting     | DEV      | UAT      | PROD     |
|-------------|----------|----------|----------|
| Performance | Standard | Standard | Standard |
| Redundancy  | LRS      | LRS      | GRS      |
| Access Tier | Hot      | Hot      | Hot      |

## Standard Containers

| Container     | Purpose                  | Access Level |
|---------------|--------------------------|--------------|
| staticfiles   | Django static assets     | Private*     |
| uploads       | User-uploaded documents  | Private      |
| exports       | Generated reports        | Private      |

> *Configure CDN or Storage static website if public access needed.

## Access Configuration

Grant Container App's Managed Identity the `Storage Blob Data Contributor` role.

Avoid using SAS tokens or connection strings in application code.

## Network Access

| Environment | Configuration            |
|-------------|--------------------------|
| DEV/UAT     | Public access allowed    |
| PROD        | Private endpoint or VNet service endpoint |

## Naming Constraint

Storage Account names must be:
- 3–24 characters
- Lowercase letters and numbers only
- Globally unique

Example: `stacmecoprod`
