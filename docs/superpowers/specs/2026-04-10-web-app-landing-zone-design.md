# Web App Landing Zone - Module Design Spec

**Date:** 2026-04-10
**Status:** Draft
**Goal:** Create 8 new Terraform modules that serve as building blocks for a web app service catalog landing zone.

## Design Principles

- **Secure by default** - private access, encryption enabled, no public exposure unless opted in
- **Composable** - each module is independently usable, but designed to wire together in a future service module
- **Consistent** - follows existing repo conventions (resource name `this`, common variables, HEREDOC descriptions, validation blocks)
- **BYOID where relevant** - the future service module handles "bring your own or create" patterns; individual modules focus on creating a single resource well

## Provider Baseline

All modules share the same provider block in `provider.tf`:

```hcl
terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
```

Additional providers are declared only when needed (e.g., `random` for PostgreSQL).

Use the ../../../scripts/scaffold.sh to create the modules

---

## Module 1: `app_service_plan`

Creates an Azure App Service Plan (Linux by default).

### Resources

- `azurerm_service_plan.this`

### Variables

| Variable                 | Type          | Required | Default   | Description                                     |
| ------------------------ | ------------- | -------- | --------- | ----------------------------------------------- |
| `name`                   | `string`      | yes      | -         | Name of the App Service Plan                    |
| `location`               | `string`      | yes      | -         | Azure region                                    |
| `resource_group_name`    | `string`      | yes      | -         | Target resource group                           |
| `os_type`                | `string`      | no       | `"Linux"` | OS type. Must be `Linux` or `Windows`           |
| `sku_name`               | `string`      | yes      | -         | The SKU for the plan (e.g., `B1`, `S1`, `P1v3`) |
| `worker_count`           | `number`      | no       | `null`    | Number of workers allocated                     |
| `zone_balancing_enabled` | `bool`        | no       | `false`   | Distribute workers across availability zones    |
| `tags`                   | `map(string)` | yes      | -         | Tags to assign                                  |

### Validations

- `os_type` must be `Linux` or `Windows`
- `sku_name` validated against known SKU patterns (regex: `^(F1|D1|B[1-3]|S[1-3]|P[1-3]v[2-3]|I[1-6]v2|Y1|EP[1-3]|WS[1-3])$`)

### Outputs

| Output    | Description                  |
| --------- | ---------------------------- |
| `id`      | ID of the App Service Plan   |
| `name`    | Name of the App Service Plan |
| `os_type` | OS type of the plan          |
| `kind`    | The kind value of the plan   |

---

## Module 2: `storage_account`

Creates a general-purpose v2 Storage Account. Secure by default: public access disabled, TLS 1.2 enforced, shared key access disabled by default.

### Resources

- `azurerm_storage_account.this`

### Variables

| Variable                          | Type            | Required | Default       | Description                                                           |
| --------------------------------- | --------------- | -------- | ------------- | --------------------------------------------------------------------- |
| `name`                            | `string`        | yes      | -             | Name of the storage account (3-24 chars, lowercase alphanumeric only) |
| `location`                        | `string`        | yes      | -             | Azure region                                                          |
| `resource_group_name`             | `string`        | yes      | -             | Target resource group                                                 |
| `account_tier`                    | `string`        | no       | `"Standard"`  | Account tier (`Standard` or `Premium`)                                |
| `account_replication_type`        | `string`        | no       | `"LRS"`       | Replication type (`LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, `RAGZRS`)     |
| `account_kind`                    | `string`        | no       | `"StorageV2"` | Account kind                                                          |
| `public_network_access_enabled`   | `bool`          | no       | `false`       | Allow public network access                                           |
| `min_tls_version`                 | `string`        | no       | `"TLS1_2"`    | Minimum TLS version                                                   |
| `allow_nested_items_to_be_public` | `bool`          | no       | `false`       | Allow blob public access                                              |
| `shared_access_key_enabled`       | `bool`          | no       | `false`       | Enable shared key authorization                                       |
| `network_rules`                   | `object({...})` | no       | `null`        | Network ACL rules                                                     |
| `blob_properties`                 | `object({...})` | no       | `null`        | Blob service properties (versioning, soft delete, CORS)               |
| `tags`                            | `map(string)`   | yes      | -             | Tags to assign                                                        |

### Variable Detail: `network_rules`

```hcl
variable "network_rules" {
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(set(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}
```

### Variable Detail: `blob_properties`

```hcl
variable "blob_properties" {
  type = object({
    versioning_enabled       = optional(bool, false)
    delete_retention_days    = optional(number, 7)
    container_delete_retention_days = optional(number, 7)
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), [])
  })
  default = null
}
```

### Validations

- `name` must match `^[a-z0-9]{3,24}$`
- `account_tier` must be `Standard` or `Premium`
- `account_replication_type` must be one of `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, `RAGZRS`
- `min_tls_version` must be `TLS1_2`

### Outputs

| Output                      | Description                           |
| --------------------------- | ------------------------------------- |
| `id`                        | ID of the storage account             |
| `name`                      | Name of the storage account           |
| `primary_blob_endpoint`     | Primary blob service endpoint         |
| `primary_access_key`        | Primary access key (sensitive)        |
| `primary_connection_string` | Primary connection string (sensitive) |

---

## Module 3: `postgresql_flexible_server`

Creates an Azure Database for PostgreSQL Flexible Server. Private access by default via delegated subnet and private DNS zone. Public access requires explicit opt-in.

### Resources

- `azurerm_postgresql_flexible_server.this`
- `azurerm_postgresql_flexible_server_firewall_rule.this` (conditional, only when public access is enabled)

### Variables

| Variable                        | Type                 | Required | Default             | Description                                                        |
| ------------------------------- | -------------------- | -------- | ------------------- | ------------------------------------------------------------------ |
| `name`                          | `string`             | yes      | -                   | Name of the PostgreSQL server                                      |
| `location`                      | `string`             | yes      | -                   | Azure region                                                       |
| `resource_group_name`           | `string`             | yes      | -                   | Target resource group                                              |
| `sku_name`                      | `string`             | no       | `"B_Standard_B1ms"` | The SKU name for the server                                        |
| `version`                       | `string`             | no       | `"16"`              | PostgreSQL major version                                           |
| `storage_mb`                    | `number`             | no       | `32768`             | Max storage in MB                                                  |
| `storage_tier`                  | `string`             | no       | `null`              | Storage tier (auto-selected if null)                               |
| `administrator_login`           | `string`             | yes      | -                   | Administrator username                                             |
| `administrator_password`        | `string`             | yes      | -                   | Administrator password (sensitive)                                 |
| `delegated_subnet_id`           | `string`             | no       | `null`              | Subnet ID for private access. When set, enables private networking |
| `private_dns_zone_id`           | `string`             | no       | `null`              | Private DNS zone ID. Required when `delegated_subnet_id` is set    |
| `public_network_access_enabled` | `bool`               | no       | `false`             | Enable public network access                                       |
| `zone`                          | `string`             | no       | `null`              | Availability zone                                                  |
| `backup_retention_days`         | `number`             | no       | `7`                 | Backup retention in days (7-35)                                    |
| `geo_redundant_backup_enabled`  | `bool`               | no       | `false`             | Enable geo-redundant backups                                       |
| `high_availability`             | `object({...})`      | no       | `null`              | High availability configuration                                    |
| `maintenance_window`            | `object({...})`      | no       | `null`              | Preferred maintenance window                                       |
| `firewall_rules`                | `map(object({...}))` | no       | `{}`                | Firewall rules (only when public access is enabled)                |
| `authentication`                | `object({...})`      | no       | see below           | Authentication configuration                                       |
| `tags`                          | `map(string)`        | yes      | -                   | Tags to assign                                                     |

### Variable Detail: `high_availability`

```hcl
variable "high_availability" {
  type = object({
    mode                      = string
    standby_availability_zone = optional(string, null)
  })
  default = null
}
```

### Variable Detail: `maintenance_window`

```hcl
variable "maintenance_window" {
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default = null
}
```

### Variable Detail: `firewall_rules`

```hcl
variable "firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}
```

### Variable Detail: `authentication`

```hcl
variable "authentication" {
  type = object({
    active_directory_auth_enabled = optional(bool, true)
    password_auth_enabled         = optional(bool, true)
    tenant_id                     = optional(string, null)
  })
  default = {}
}
```

### Validations

- `version` must be one of `"13"`, `"14"`, `"15"`, `"16"`
- `backup_retention_days` must be between 7 and 35
- `delegated_subnet_id` and `private_dns_zone_id` must both be set or both be null
- `firewall_rules` must be empty when `public_network_access_enabled` is `false`

### Design Notes

- When `delegated_subnet_id` is set, the server is deployed into a VNet-integrated subnet with private DNS resolution. This is the preferred and default path.
- When `delegated_subnet_id` is null and `public_network_access_enabled` is true, the server is publicly accessible with firewall rules controlling access.
- When both are null/false, the server is created with no network access (locked down).

### Outputs

| Output | Description                   |
| ------ | ----------------------------- |
| `id`   | ID of the PostgreSQL server   |
| `name` | Name of the PostgreSQL server |
| `fqdn` | Fully qualified domain name   |

---

## Module 4: `user_assigned_identity`

Creates a User Assigned Managed Identity with optional federated identity credentials for workload identity federation.

### Resources

- `azurerm_user_assigned_identity.this`
- `azurerm_federated_identity_credential.this` (conditional, `for_each`)

### Variables

| Variable                         | Type                 | Required | Default | Description                                          |
| -------------------------------- | -------------------- | -------- | ------- | ---------------------------------------------------- |
| `name`                           | `string`             | yes      | -       | Name of the managed identity                         |
| `location`                       | `string`             | yes      | -       | Azure region                                         |
| `resource_group_name`            | `string`             | yes      | -       | Target resource group                                |
| `federated_identity_credentials` | `map(object({...}))` | no       | `{}`    | Federated identity credentials for workload identity |
| `tags`                           | `map(string)`        | yes      | -       | Tags to assign                                       |

### Variable Detail: `federated_identity_credentials`

```hcl
variable "federated_identity_credentials" {
  type = map(object({
    audience = optional(list(string), ["api://AzureADTokenExchange"])
    issuer   = string
    subject  = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of federated identity credentials to create.

- `audience` - (Optional) The audience for the credential. Defaults to `["api://AzureADTokenExchange"]`.
- `issuer` - The OpenID Connect issuer URL (e.g., `https://token.actions.githubusercontent.com` for GitHub Actions).
- `subject` - The subject identifier (e.g., `repo:org/repo:ref:refs/heads/main` for GitHub Actions).
DESCRIPTION
}
```

### Outputs

| Output         | Description                                   |
| -------------- | --------------------------------------------- |
| `id`           | ID of the managed identity                    |
| `principal_id` | Principal (object) ID of the managed identity |
| `client_id`    | Client ID of the managed identity             |
| `tenant_id`    | Tenant ID of the managed identity             |

---

## Module 5: `diagnostic_setting`

Creates an Azure Monitor diagnostic setting. Generic module that attaches to any resource by ID.

### Resources

- `azurerm_monitor_diagnostic_setting.this`

### Variables

| Variable                         | Type          | Required | Default | Description                                                                  |
| -------------------------------- | ------------- | -------- | ------- | ---------------------------------------------------------------------------- |
| `name`                           | `string`      | yes      | -       | Name of the diagnostic setting                                               |
| `target_resource_id`             | `string`      | yes      | -       | ID of the resource to attach diagnostics to                                  |
| `log_analytics_workspace_id`     | `string`      | no       | `null`  | Log Analytics workspace ID as destination                                    |
| `storage_account_id`             | `string`      | no       | `null`  | Storage account ID as destination (for archival)                             |
| `enabled_log_categories`         | `set(string)` | no       | `null`  | Log categories to enable. When null, all available categories are enabled    |
| `metric_categories`              | `set(string)` | no       | `null`  | Metric categories to enable. When null, all available categories are enabled |
| `log_analytics_destination_type` | `string`      | no       | `null`  | Destination table type: `Dedicated` or `AzureDiagnostics`                    |

### Validations

- At least one destination must be provided (`log_analytics_workspace_id` or `storage_account_id`)

### Design Notes

- The module uses dynamic blocks to iterate over `enabled_log_categories` and `metric_categories`.
- When category sets are null, the module enables all available categories. This is the recommended default - capture everything and filter at query time.
- No `tags` variable: `azurerm_monitor_diagnostic_setting` does not support tags.

### Outputs

| Output | Description                  |
| ------ | ---------------------------- |
| `id`   | ID of the diagnostic setting |

---

## Module 6: `container_registry`

Creates an Azure Container Registry. Standard SKU by default, no admin user, no Basic SKU allowed.

### Resources

- `azurerm_container_registry.this`

### Variables

| Variable                        | Type                  | Required | Default           | Description                                                                      |
| ------------------------------- | --------------------- | -------- | ----------------- | -------------------------------------------------------------------------------- |
| `name`                          | `string`              | yes      | -                 | Name of the container registry (5-50 chars, alphanumeric only)                   |
| `location`                      | `string`              | yes      | -                 | Azure region                                                                     |
| `resource_group_name`           | `string`              | yes      | -                 | Target resource group                                                            |
| `sku`                           | `string`              | no       | `"Standard"`      | SKU tier. Must be `Standard` or `Premium`                                        |
| `admin_enabled`                 | `bool`                | no       | `false`           | Enable admin user                                                                |
| `public_network_access_enabled` | `bool`                | no       | `true`            | Allow public network access. Set to false with Premium SKU and private endpoints |
| `network_rule_bypass_option`    | `string`              | no       | `"AzureServices"` | Allow trusted Azure services to bypass network rules                             |
| `georeplications`               | `list(object({...}))` | no       | `[]`              | Geo-replication locations (Premium only)                                         |
| `retention_policy_days`         | `number`              | no       | `7`               | Days to retain untagged manifests (Premium only)                                 |
| `tags`                          | `map(string)`         | yes      | -                 | Tags to assign                                                                   |

### Variable Detail: `georeplications`

```hcl
variable "georeplications" {
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool, false)
  }))
  default = []
}
```

### Validations

- `name` must match `^[a-zA-Z0-9]{5,50}$`
- `sku` must be `Standard` or `Premium`
- `georeplications` must be empty when `sku` is `Standard`
- `public_network_access_enabled` must be `true` when `sku` is `Standard` (private endpoints require Premium)

### Design Notes

- No Basic SKU. Validation explicitly rejects it.
- `admin_enabled` defaults to `false`. Managed identity is the intended auth mechanism.
- Georeplications and retention policies are gated behind Premium via validation.

### Outputs

| Output         | Description                    |
| -------------- | ------------------------------ |
| `id`           | ID of the container registry   |
| `name`         | Name of the container registry |
| `login_server` | Login server URL               |

---

## Module 7: `log_analytics_workspace`

Creates an Azure Log Analytics Workspace.

### Resources

- `azurerm_log_analytics_workspace.this`

### Variables

| Variable              | Type          | Required | Default       | Description                                       |
| --------------------- | ------------- | -------- | ------------- | ------------------------------------------------- |
| `name`                | `string`      | yes      | -             | Name of the workspace                             |
| `location`            | `string`      | yes      | -             | Azure region                                      |
| `resource_group_name` | `string`      | yes      | -             | Target resource group                             |
| `sku`                 | `string`      | no       | `"PerGB2018"` | Pricing tier                                      |
| `retention_in_days`   | `number`      | no       | `30`          | Data retention in days (30-730)                   |
| `daily_quota_gb`      | `number`      | no       | `null`        | Daily ingestion quota in GB. Null means unlimited |
| `tags`                | `map(string)` | yes      | -             | Tags to assign                                    |

### Validations

- `retention_in_days` must be between 30 and 730
- `daily_quota_gb` must be greater than 0 when set

### Outputs

| Output               | Description                    |
| -------------------- | ------------------------------ |
| `id`                 | ID of the workspace            |
| `workspace_id`       | The unique workspace GUID      |
| `primary_shared_key` | Primary shared key (sensitive) |

---

## Module 8: `application_insights`

Creates an Azure Application Insights instance linked to a Log Analytics Workspace (workspace-based, as classic mode is deprecated).

### Resources

- `azurerm_application_insights.this`

### Variables

| Variable               | Type          | Required | Default | Description                               |
| ---------------------- | ------------- | -------- | ------- | ----------------------------------------- |
| `name`                 | `string`      | yes      | -       | Name of the Application Insights instance |
| `location`             | `string`      | yes      | -       | Azure region                              |
| `resource_group_name`  | `string`      | yes      | -       | Target resource group                     |
| `application_type`     | `string`      | no       | `"web"` | Application type                          |
| `workspace_id`         | `string`      | yes      | -       | Log Analytics workspace ID to link to     |
| `retention_in_days`    | `number`      | no       | `90`    | Data retention in days                    |
| `daily_data_cap_in_gb` | `number`      | no       | `null`  | Daily data volume cap in GB               |
| `sampling_percentage`  | `number`      | no       | `100`   | Percentage of telemetry sampled (0-100)   |
| `disable_ip_masking`   | `bool`        | no       | `false` | Disable IP masking in logs                |
| `tags`                 | `map(string)` | yes      | -       | Tags to assign                            |

### Validations

- `application_type` must be one of `web`, `ios`, `java`, `MobileCenter`, `Node.JS`, `other`, `phone`, `store`
- `retention_in_days` must be one of `30`, `60`, `90`, `120`, `180`, `270`, `365`, `550`, `730`
- `sampling_percentage` must be between 0 and 100

### Outputs

| Output                | Description                             |
| --------------------- | --------------------------------------- |
| `id`                  | ID of the Application Insights instance |
| `instrumentation_key` | Instrumentation key (sensitive)         |
| `connection_string`   | Connection string (sensitive)           |
| `app_id`              | Application ID                          |

---

## Future: Service Module Composition

These 8 modules, combined with the existing modules (key_vault, web_app, resource_group, subnet, virtual_network, private_endpoint), will compose into a `web_app_landing_zone` service module. That service module will:

- Accept an optional `app_service_plan_id` (BYOID) or create a new one
- Wire managed identity to Key Vault, Storage, PostgreSQL, and ACR via role assignments
- Create diagnostic settings for each resource, all pointing to the shared Log Analytics workspace
- Connect Application Insights to the web app via app settings
- Default to private networking with private endpoints where applicable

The service module design will be a separate spec once these building blocks exist.

---

## File Layout Per Module

Each module follows the repository standard:

```
modules/<module_name>/
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── README.md
├── .terraform-docs.yml
└── examples/
    └── default/
        ├── main.tf
        └── provider.tf
```

## Implementation Order

Modules are independent, so they can be built in parallel. However, a logical order based on dependency for the eventual service module:

1. `log_analytics_workspace` - no dependencies
2. `application_insights` - depends on workspace conceptually
3. `user_assigned_identity` - no dependencies
4. `app_service_plan` - no dependencies
5. `storage_account` - no dependencies
6. `container_registry` - no dependencies
7. `postgresql_flexible_server` - no dependencies
8. `diagnostic_setting` - no dependencies (generic)

All 8 are independent at the individual module level and can be implemented concurrently.
