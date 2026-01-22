# Azure Storage Account

Blob storage for static files and document uploads.

## Configuration

| Setting     | DEV      | UAT      | PROD     |
|-------------|----------|----------|----------|
| Performance | Standard | Standard | Standard |
| Redundancy  | LRS      | LRS      | GRS      |
| Access Tier | Hot      | Hot      | Hot      |

## Blob Containers

### Default Containers

The Terraform configuration creates two containers by default, please update these as needed:

| Container | Purpose | Access Level | Use Case |
|-----------|---------|--------------|----------|
| **static** | Static web assets (CSS, JavaScript, images) | **Blob** (public read) | Frontend UI files that need to be publicly accessible |
| **uploads** | User-uploaded documents | **Private** | Sensitive user data, application documents |

### Access Level Explained

| Access Level | Public Access | Authentication Required | Typical Use |
|--------------|---------------|-------------------------|-------------|
| **Private** | ❌ No | ✅ Yes (Azure AD, SAS token, or access key) | Sensitive data, user uploads, application data |
| **Blob** | ✅ Yes (read-only) | ❌ No (anonymous read allowed) | Public static assets (CSS, JS, images) |
| **Container** | ✅ Yes (read + list) | ❌ No | Rarely used (allows listing all files) |

**Important:** "Blob" access level allows anonymous users to READ blobs if they know the URL, but does NOT allow listing containers or blobs. This is suitable for static assets referenced from HTML/CSS.

### Container Purposes and Access Patterns

#### Static Container (Public)

**Purpose:** Host static web assets that the browser loads directly.


#### Uploads Container (Private)

**Purpose:** Store user-uploaded documents and application-generated data securely.


### Adding New Containers

To add additional containers, update the `blob_containers` variable in your environment's `terraform.tfvars`:

```hcl
blob_containers = {
  "static"   = "blob"      # Public static assets
  "uploads"  = "private"   # User uploads
  "backups"  = "private"   # New: Application backups
  "exports"  = "private"   # New: Generated exports
}
```

**Container naming rules:**
- Must be lowercase
- 3-63 characters
- Letters, numbers, and hyphens only
- Cannot start or end with hyphen
- No consecutive hyphens

**Examples:**
- ✅ `user-uploads`
- ✅ `static-assets-v2`
- ✅ `backup123`
- ❌ `UserUploads` (uppercase not allowed)
- ❌ `-backups` (cannot start with hyphen)
- ❌ `my--container` (consecutive hyphens not allowed)

## CORS Configuration

**Cross-Origin Resource Sharing (CORS)** is enabled on the main storage account to allow web browsers to access static files from different domains.

### Current Configuration

| Setting | Value | Purpose |
|---------|-------|---------|
| **Allowed Origins** | `*` (all) | Allows any website to load static assets |
| **Allowed Methods** | GET, HEAD, OPTIONS | Read-only operations |
| **Max Age** | 3600 seconds (1 hour) | Browser caches preflight responses |

### Why CORS Matters

Without CORS, browsers block requests to storage account URLs from web applications hosted on different domains. This is a browser security feature called the "Same-Origin Policy."

## Access Configuration

### Managed Identity (Recommended)

Grant Container App and Function App managed identities the `Storage Blob Data Contributor` role for full read/write access.

**This is configured automatically by Terraform** for the Function App.

**Role permissions:**
- ✅ Read blobs
- ✅ Write blobs
- ✅ Delete blobs
- ✅ List containers and blobs

### Alternative Authentication Methods

| Method | Use Case | Security Level | Recommended? |
|--------|----------|----------------|--------------|
| **Managed Identity** | Application access | ✅ High (no credentials to store) | ✅ Yes |
| **SAS Token** | Temporary access, third-party integrations | ⚠️ Medium (time-limited, scoped) | ⚠️ Use sparingly |
| **Access Key** | Legacy applications | ❌ Low (full account access) | ❌ Avoid |

**Best practice:** Avoid using SAS tokens or connection strings in application code. Use managed identities whenever possible.

## Network Access

| Environment | Configuration            |
|-------------|--------------------------|
| DEV/UAT     | Public access allowed    |
| PROD        | Private endpoint or VNet service endpoint |

## Cost Optimization

### Storage Tiers

| Tier | Use Case | Cost | Access Cost |
|------|----------|------|-------------|
| **Hot** (current) | Frequently accessed data | $$$ | $ |
| **Cool** | Infrequently accessed (< 1x/month) | $$ | $$ |
| **Archive** | Rarely accessed (< 1x/year) | $ | $$$ |

**Current configuration:** All data in Hot tier.

**Optimization opportunities:**
- Move old uploads (> 6 months) to Cool tier
- Move archived reports (> 1 year) to Archive tier
- Use lifecycle policies to automate tiering

### Redundancy Options

| Option | Description | Cost | Use Case |
|--------|-------------|------|----------|
| **LRS** (UAT) | 3 copies in one datacenter | $ | Development, non-critical data |
| **GRS** (PROD) | 6 copies across two regions | $$$ | Production, business-critical data |
| **ZRS** | 3 copies across availability zones | $$ | Balance between cost and availability |

**Cost savings:** LRS is ~50% cheaper than GRS but provides lower durability guarantees.

### Cost Monitoring

**Estimated monthly costs:**

| Environment | Storage Size | Redundancy | Estimated Cost |
|-------------|-------------|------------|----------------|
| UAT | 100 GB | LRS | ~$2-3/month |
| PROD | 500 GB | GRS | ~$25-30/month |

**Factors affecting cost:**
- Storage capacity ($/GB)
- Redundancy tier (LRS vs GRS)
- Access tier (Hot, Cool, Archive)
- Data transfer out (egress)
- Operations (reads, writes, lists)

**Monitor usage:**
```bash
# View storage metrics
az monitor metrics list \
  --resource /subscriptions/.../storageAccounts/stmyprojectuat \
  --metric UsedCapacity \
  --start-time 2024-01-01T00:00:00Z
```