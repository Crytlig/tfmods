# Web App Landing Zone Modules - Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create 8 new Terraform modules as building blocks for a web app service catalog landing zone.

**Architecture:** Each module wraps a single Azure resource (or small cluster), follows the existing repo conventions (`this` naming, common variables, HEREDOC descriptions, validation blocks), and defaults to secure configuration. All modules are independent and can be built in parallel.

**Tech Stack:** Terraform >= 1.6, azurerm ~> 4.0

**Working directory:** `/Users/cliff/repos/tfmods/.worktrees/web-app-landing-zone`

**Reference module:** `modules/key_vault/` - use its patterns for variable structure, validations, HEREDOC descriptions, dynamic blocks, and output style.

**Conventions:**
- Resource name: `this` (e.g., `azurerm_service_plan.this`)
- Required variables first, then optional with defaults
- Every variable has `type` and `description`
- Use `validation` blocks for constraints
- Use HEREDOC (`<<DESCRIPTION ... DESCRIPTION`) for multi-line descriptions on complex object variables
- Use `dynamic` blocks for optional nested config
- `tags = var.tags` as last argument before blocks
- `provider.tf` has `required_version` and `required_providers` only - never a `provider` block
- Examples `provider.tf` includes the `provider "azurerm" { features {} }` block
- `.terraform-docs.yml` follows the template format with module-specific title and description

**Verification per module:**
```bash
cd modules/<module_name>
terraform fmt -check
terraform init -backend=false
terraform validate
```

---

### Task 1: `log_analytics_workspace`

**Files:**
- Create: `modules/log_analytics_workspace/main.tf`
- Create: `modules/log_analytics_workspace/variables.tf`
- Create: `modules/log_analytics_workspace/outputs.tf`
- Create: `modules/log_analytics_workspace/provider.tf`
- Create: `modules/log_analytics_workspace/README.md`
- Create: `modules/log_analytics_workspace/.terraform-docs.yml`
- Create: `modules/log_analytics_workspace/examples/default/main.tf`
- Create: `modules/log_analytics_workspace/examples/default/provider.tf`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p modules/log_analytics_workspace/examples/default
touch modules/log_analytics_workspace/README.md
```

- [ ] **Step 2: Write `provider.tf`**

Write to `modules/log_analytics_workspace/provider.tf`:

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

- [ ] **Step 3: Write `variables.tf`**

Write to `modules/log_analytics_workspace/variables.tf`:

```hcl
variable "name" {
  type        = string
  description = "The name of the Log Analytics Workspace."
}

variable "location" {
  type        = string
  description = "The Azure region where the workspace will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "sku" {
  type        = string
  default     = "PerGB2018"
  description = "The SKU (pricing tier) of the Log Analytics Workspace."

  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.sku)
    error_message = "The SKU must be one of: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018."
  }
}

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "The number of days to retain data. Valid range is 30 to 730."

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
  validation {
    condition     = ceil(var.retention_in_days) == var.retention_in_days
    error_message = "Retention must be a whole number."
  }
}

variable "daily_quota_gb" {
  type        = number
  default     = null
  description = "The daily ingestion quota in GB. Null means unlimited."

  validation {
    condition     = var.daily_quota_gb == null ? true : var.daily_quota_gb > 0
    error_message = "Daily quota must be greater than 0 when set."
  }
}
```

- [ ] **Step 4: Write `main.tf`**

Write to `modules/log_analytics_workspace/main.tf`:

```hcl
resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb
  tags                = var.tags
}
```

- [ ] **Step 5: Write `outputs.tf`**

Write to `modules/log_analytics_workspace/outputs.tf`:

```hcl
output "id" {
  description = "ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_id" {
  description = "The unique workspace GUID."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "primary_shared_key" {
  description = "The primary shared key of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}
```

- [ ] **Step 6: Write `.terraform-docs.yml`**

Write to `modules/log_analytics_workspace/.terraform-docs.yml`:

```yaml
formatter: "md table"

version: ""

header-from: main.tf
footer-from: ""

sections:
  hide: []
  show: []

content: |-
  # Log Analytics Workspace

  This module creates an Azure Log Analytics Workspace with configurable retention and ingestion quotas.

  {{ .Header }}

  {{ .Inputs }}

  {{ .Outputs }}

  # Examples

  ## Default
  ```hcl
  {{ include "examples/default/main.tf" }}
  ```

output:
  file: "README.md"
  path: "."

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: false
  read-comments: true
  required: true
  sensitive: true
  type: true
```

- [ ] **Step 7: Write example files**

Write to `modules/log_analytics_workspace/examples/default/provider.tf`:

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
provider "azurerm" {
  features {}
}
```

Write to `modules/log_analytics_workspace/examples/default/main.tf`:

```hcl
module "log_analytics_workspace" {
  # source = "github.com/crytlig/tfmods//modules/log_analytics_workspace?ref=main"
  source = "../../"

  name                = "law-example"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30

  tags = {
    environment = "dev"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "rg-law-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
```

- [ ] **Step 8: Validate**

```bash
cd modules/log_analytics_workspace
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

- [ ] **Step 9: Commit**

```bash
git restore --staged :/
git add "modules/log_analytics_workspace"
git commit -m "feat(log_analytics_workspace): add module" -- "modules/log_analytics_workspace"
```

---

### Task 2: `application_insights`

**Files:**
- Create: `modules/application_insights/main.tf`
- Create: `modules/application_insights/variables.tf`
- Create: `modules/application_insights/outputs.tf`
- Create: `modules/application_insights/provider.tf`
- Create: `modules/application_insights/README.md`
- Create: `modules/application_insights/.terraform-docs.yml`
- Create: `modules/application_insights/examples/default/main.tf`
- Create: `modules/application_insights/examples/default/provider.tf`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p modules/application_insights/examples/default
touch modules/application_insights/README.md
```

- [ ] **Step 2: Write `provider.tf`**

Write to `modules/application_insights/provider.tf`:

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

- [ ] **Step 3: Write `variables.tf`**

Write to `modules/application_insights/variables.tf`:

```hcl
variable "name" {
  type        = string
  description = "The name of the Application Insights instance."
}

variable "location" {
  type        = string
  description = "The Azure region where the resource will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace to link to. Required for workspace-based Application Insights."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "application_type" {
  type        = string
  default     = "web"
  description = "The type of Application Insights to create."

  validation {
    condition     = contains(["web", "ios", "java", "MobileCenter", "Node.JS", "other", "phone", "store"], var.application_type)
    error_message = "The application_type must be one of: web, ios, java, MobileCenter, Node.JS, other, phone, store."
  }
}

variable "retention_in_days" {
  type        = number
  default     = 90
  description = "The number of days to retain data."

  validation {
    condition     = contains([30, 60, 90, 120, 180, 270, 365, 550, 730], var.retention_in_days)
    error_message = "Retention must be one of: 30, 60, 90, 120, 180, 270, 365, 550, 730."
  }
}

variable "daily_data_cap_in_gb" {
  type        = number
  default     = null
  description = "The daily data volume cap in GB. Null means no cap."

  validation {
    condition     = var.daily_data_cap_in_gb == null ? true : var.daily_data_cap_in_gb > 0
    error_message = "Daily data cap must be greater than 0 when set."
  }
}

variable "sampling_percentage" {
  type        = number
  default     = 100
  description = "The percentage of telemetry items to sample (0-100)."

  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 0 and 100."
  }
}

variable "disable_ip_masking" {
  type        = bool
  default     = false
  description = "Disable IP masking in logs. When false (default), client IPs are masked."
}
```

- [ ] **Step 4: Write `main.tf`**

Write to `modules/application_insights/main.tf`:

```hcl
resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = var.workspace_id
  application_type    = var.application_type
  retention_in_days   = var.retention_in_days
  daily_data_cap_in_gb = var.daily_data_cap_in_gb
  sampling_percentage = var.sampling_percentage
  disable_ip_masking  = var.disable_ip_masking
  tags                = var.tags
}
```

- [ ] **Step 5: Write `outputs.tf`**

Write to `modules/application_insights/outputs.tf`:

```hcl
output "id" {
  description = "ID of the Application Insights instance."
  value       = azurerm_application_insights.this.id
}

output "instrumentation_key" {
  description = "The instrumentation key of the Application Insights instance."
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "The connection string of the Application Insights instance."
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}

output "app_id" {
  description = "The application ID of the Application Insights instance."
  value       = azurerm_application_insights.this.app_id
}
```

- [ ] **Step 6: Write `.terraform-docs.yml`**

Write to `modules/application_insights/.terraform-docs.yml`:

```yaml
formatter: "md table"

version: ""

header-from: main.tf
footer-from: ""

sections:
  hide: []
  show: []

content: |-
  # Application Insights

  This module creates a workspace-based Azure Application Insights instance linked to a Log Analytics Workspace.

  {{ .Header }}

  {{ .Inputs }}

  {{ .Outputs }}

  # Examples

  ## Default
  ```hcl
  {{ include "examples/default/main.tf" }}
  ```

output:
  file: "README.md"
  path: "."

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: false
  read-comments: true
  required: true
  sensitive: true
  type: true
```

- [ ] **Step 7: Write example files**

Write to `modules/application_insights/examples/default/provider.tf`:

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
provider "azurerm" {
  features {}
}
```

Write to `modules/application_insights/examples/default/main.tf`:

```hcl
module "application_insights" {
  # source = "github.com/crytlig/tfmods//modules/application_insights?ref=main"
  source = "../../"

  name                = "appi-example"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example.id

  tags = {
    environment = "dev"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "rg-appi-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-appi-example"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = "dev"
  }
}
```

- [ ] **Step 8: Validate**

```bash
cd modules/application_insights
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

- [ ] **Step 9: Commit**

```bash
git restore --staged :/
git add "modules/application_insights"
git commit -m "feat(application_insights): add module" -- "modules/application_insights"
```

---

### Task 3: `user_assigned_identity`

**Files:**
- Create: `modules/user_assigned_identity/main.tf`
- Create: `modules/user_assigned_identity/variables.tf`
- Create: `modules/user_assigned_identity/outputs.tf`
- Create: `modules/user_assigned_identity/provider.tf`
- Create: `modules/user_assigned_identity/README.md`
- Create: `modules/user_assigned_identity/.terraform-docs.yml`
- Create: `modules/user_assigned_identity/examples/default/main.tf`
- Create: `modules/user_assigned_identity/examples/default/provider.tf`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p modules/user_assigned_identity/examples/default
touch modules/user_assigned_identity/README.md
```

- [ ] **Step 2: Write `provider.tf`**

Write to `modules/user_assigned_identity/provider.tf`:

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

- [ ] **Step 3: Write `variables.tf`**

Write to `modules/user_assigned_identity/variables.tf`:

```hcl
variable "name" {
  type        = string
  description = "The name of the User Assigned Managed Identity."
}

variable "location" {
  type        = string
  description = "The Azure region where the resource will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "federated_identity_credentials" {
  type = map(object({
    audience = optional(list(string), ["api://AzureADTokenExchange"])
    issuer   = string
    subject  = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of federated identity credentials to create on the managed identity.
The map key is used as the credential name.

- `audience` - (Optional) The audience for the credential. Defaults to `["api://AzureADTokenExchange"]`.
- `issuer` - The OpenID Connect issuer URL (e.g., `https://token.actions.githubusercontent.com` for GitHub Actions).
- `subject` - The subject identifier (e.g., `repo:org/repo:ref:refs/heads/main` for GitHub Actions).
DESCRIPTION
}
```

- [ ] **Step 4: Write `main.tf`**

Write to `modules/user_assigned_identity/main.tf`:

```hcl
resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "this" {
  for_each = var.federated_identity_credentials

  name                = each.key
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  audience            = each.value.audience
  issuer              = each.value.issuer
  subject             = each.value.subject
}
```

- [ ] **Step 5: Write `outputs.tf`**

Write to `modules/user_assigned_identity/outputs.tf`:

```hcl
output "id" {
  description = "ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "principal_id" {
  description = "The principal (object) ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "client_id" {
  description = "The client ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "tenant_id" {
  description = "The tenant ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.tenant_id
}
```

- [ ] **Step 6: Write `.terraform-docs.yml`**

Write to `modules/user_assigned_identity/.terraform-docs.yml`:

```yaml
formatter: "md table"

version: ""

header-from: main.tf
footer-from: ""

sections:
  hide: []
  show: []

content: |-
  # User Assigned Identity

  This module creates a User Assigned Managed Identity with optional federated identity credentials for workload identity federation.

  {{ .Header }}

  {{ .Inputs }}

  {{ .Outputs }}

  # Examples

  ## Default
  ```hcl
  {{ include "examples/default/main.tf" }}
  ```

output:
  file: "README.md"
  path: "."

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: false
  read-comments: true
  required: true
  sensitive: true
  type: true
```

- [ ] **Step 7: Write example files**

Write to `modules/user_assigned_identity/examples/default/provider.tf`:

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
provider "azurerm" {
  features {}
}
```

Write to `modules/user_assigned_identity/examples/default/main.tf`:

```hcl
module "user_assigned_identity" {
  # source = "github.com/crytlig/tfmods//modules/user_assigned_identity?ref=main"
  source = "../../"

  name                = "id-example"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name

  federated_identity_credentials = {
    github_actions = {
      issuer  = "https://token.actions.githubusercontent.com"
      subject = "repo:example-org/example-repo:ref:refs/heads/main"
    }
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "rg-id-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
```

- [ ] **Step 8: Validate**

```bash
cd modules/user_assigned_identity
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

- [ ] **Step 9: Commit**

```bash
git restore --staged :/
git add "modules/user_assigned_identity"
git commit -m "feat(user_assigned_identity): add module" -- "modules/user_assigned_identity"
```

---

### Task 4: `app_service_plan`

**Files:**
- Create: `modules/app_service_plan/main.tf`
- Create: `modules/app_service_plan/variables.tf`
- Create: `modules/app_service_plan/outputs.tf`
- Create: `modules/app_service_plan/provider.tf`
- Create: `modules/app_service_plan/README.md`
- Create: `modules/app_service_plan/.terraform-docs.yml`
- Create: `modules/app_service_plan/examples/default/main.tf`
- Create: `modules/app_service_plan/examples/default/provider.tf`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p modules/app_service_plan/examples/default
touch modules/app_service_plan/README.md
```

- [ ] **Step 2: Write `provider.tf`**

Write to `modules/app_service_plan/provider.tf`:

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

- [ ] **Step 3: Write `variables.tf`**

Write to `modules/app_service_plan/variables.tf`:

```hcl
variable "name" {
  type        = string
  description = "The name of the App Service Plan."
}

variable "location" {
  type        = string
  description = "The Azure region where the resource will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "sku_name" {
  type        = string
  description = "The SKU for the App Service Plan (e.g., B1, S1, P1v3)."

  validation {
    condition     = can(regex("^(F1|D1|B[1-3]|S[1-3]|P[1-3]v[2-3]|I[1-6]v2|Y1|EP[1-3]|WS[1-3])$", var.sku_name))
    error_message = "The SKU name must be a valid App Service Plan SKU (e.g., F1, B1, S1, P1v2, P1v3, I1v2, Y1, EP1, WS1)."
  }
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "os_type" {
  type        = string
  default     = "Linux"
  description = "The OS type for the App Service Plan. Must be `Linux` or `Windows`."

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "The os_type must be either Linux or Windows."
  }
}

variable "worker_count" {
  type        = number
  default     = null
  description = "The number of workers (instances) to allocate."

  validation {
    condition     = var.worker_count == null ? true : var.worker_count > 0
    error_message = "Worker count must be greater than 0 when set."
  }
}

variable "zone_balancing_enabled" {
  type        = bool
  default     = false
  description = "Should workers be distributed across availability zones. Requires a zone-redundant SKU."
}
```

- [ ] **Step 4: Write `main.tf`**

Write to `modules/app_service_plan/main.tf`:

```hcl
resource "azurerm_service_plan" "this" {
  name                   = var.name
  location               = var.location
  resource_group_name    = var.resource_group_name
  os_type                = var.os_type
  sku_name               = var.sku_name
  worker_count           = var.worker_count
  zone_balancing_enabled = var.zone_balancing_enabled
  tags                   = var.tags
}
```

- [ ] **Step 5: Write `outputs.tf`**

Write to `modules/app_service_plan/outputs.tf`:

```hcl
output "id" {
  description = "ID of the App Service Plan."
  value       = azurerm_service_plan.this.id
}

output "name" {
  description = "Name of the App Service Plan."
  value       = azurerm_service_plan.this.name
}

output "os_type" {
  description = "The OS type of the App Service Plan."
  value       = azurerm_service_plan.this.os_type
}

output "kind" {
  description = "The kind value of the App Service Plan."
  value       = azurerm_service_plan.this.kind
}
```

- [ ] **Step 6: Write `.terraform-docs.yml`**

Write to `modules/app_service_plan/.terraform-docs.yml`:

```yaml
formatter: "md table"

version: ""

header-from: main.tf
footer-from: ""

sections:
  hide: []
  show: []

content: |-
  # App Service Plan

  This module creates an Azure App Service Plan for hosting web apps, APIs, and functions.

  {{ .Header }}

  {{ .Inputs }}

  {{ .Outputs }}

  # Examples

  ## Default
  ```hcl
  {{ include "examples/default/main.tf" }}
  ```

output:
  file: "README.md"
  path: "."

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: false
  read-comments: true
  required: true
  sensitive: true
  type: true
```

- [ ] **Step 7: Write example files**

Write to `modules/app_service_plan/examples/default/provider.tf`:

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
provider "azurerm" {
  features {}
}
```

Write to `modules/app_service_plan/examples/default/main.tf`:

```hcl
module "app_service_plan" {
  # source = "github.com/crytlig/tfmods//modules/app_service_plan?ref=main"
  source = "../../"

  name                = "asp-example"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "B1"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "rg-asp-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
```

- [ ] **Step 8: Validate**

```bash
cd modules/app_service_plan
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

- [ ] **Step 9: Commit**

```bash
git restore --staged :/
git add "modules/app_service_plan"
git commit -m "feat(app_service_plan): add module" -- "modules/app_service_plan"
```

---

### Task 5: `storage_account`

**Files:**
- Create: `modules/storage_account/main.tf`
- Create: `modules/storage_account/variables.tf`
- Create: `modules/storage_account/outputs.tf`
- Create: `modules/storage_account/provider.tf`
- Create: `modules/storage_account/README.md`
- Create: `modules/storage_account/.terraform-docs.yml`
- Create: `modules/storage_account/examples/default/main.tf`
- Create: `modules/storage_account/examples/default/provider.tf`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p modules/storage_account/examples/default
touch modules/storage_account/README.md
```

- [ ] **Step 2: Write `provider.tf`**

Write to `modules/storage_account/provider.tf`:

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

- [ ] **Step 3: Write `variables.tf`**

Write to `modules/storage_account/variables.tf`:

```hcl
variable "name" {
  type        = string
  description = "The name of the storage account. Must be 3-24 characters, lowercase letters and numbers only."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "The name must be between 3 and 24 characters long and can only contain lowercase letters and numbers."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where the resource will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "The tier of the storage account."

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "The account_tier must be either Standard or Premium."
  }
}

variable "account_replication_type" {
  type        = string
  default     = "LRS"
  description = "The replication type of the storage account."

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "The account_replication_type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "The kind of storage account."

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "The account_kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Allow public network access to the storage account. Defaults to false (secure by default)."
}

variable "min_tls_version" {
  type        = string
  default     = "TLS1_2"
  description = "The minimum supported TLS version."

  validation {
    condition     = var.min_tls_version == "TLS1_2"
    error_message = "The minimum TLS version must be TLS1_2."
  }
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  default     = false
  description = "Allow or disallow nested items within this account to opt into being public."
}

variable "shared_access_key_enabled" {
  type        = bool
  default     = false
  description = "Enable shared key authorization. Defaults to false - use Entra ID (RBAC) instead."
}

variable "network_rules" {
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(set(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default     = null
  description = <<DESCRIPTION
Network ACL rules for the storage account. When null, no explicit network rules are set.

- `default_action` - (Optional) The default action when no rule matches. Defaults to `Deny`.
- `bypass` - (Optional) Services allowed to bypass the rules. Defaults to `["AzureServices"]`.
- `ip_rules` - (Optional) List of IP CIDR ranges to allow.
- `virtual_network_subnet_ids` - (Optional) List of subnet IDs to allow.
DESCRIPTION

  validation {
    condition     = var.network_rules == null ? true : contains(["Allow", "Deny"], var.network_rules.default_action)
    error_message = "The default_action must be either Allow or Deny."
  }
}

variable "blob_properties" {
  type = object({
    versioning_enabled              = optional(bool, false)
    delete_retention_days           = optional(number, 7)
    container_delete_retention_days = optional(number, 7)
    cors_rule = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), [])
  })
  default     = null
  description = <<DESCRIPTION
Blob service properties for the storage account. When null, defaults are used.

- `versioning_enabled` - (Optional) Enable blob versioning. Defaults to false.
- `delete_retention_days` - (Optional) Days to retain deleted blobs. Defaults to 7.
- `container_delete_retention_days` - (Optional) Days to retain deleted containers. Defaults to 7.
- `cors_rule` - (Optional) CORS rules for blob service.
DESCRIPTION
}
```

- [ ] **Step 4: Write `main.tf`**

Write to `modules/storage_account/main.tf`:

```hcl
resource "azurerm_storage_account" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  public_network_access_enabled   = var.public_network_access_enabled
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  tags                            = var.tags

  dynamic "network_rules" {
    for_each = var.network_rules != null ? { this = var.network_rules } : {}
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  dynamic "blob_properties" {
    for_each = var.blob_properties != null ? { this = var.blob_properties } : {}
    content {
      versioning_enabled = blob_properties.value.versioning_enabled

      delete_retention_policy {
        days = blob_properties.value.delete_retention_days
      }

      container_delete_retention_policy {
        days = blob_properties.value.container_delete_retention_days
      }

      dynamic "cors_rule" {
        for_each = blob_properties.value.cors_rule
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
    }
  }
}
```

- [ ] **Step 5: Write `outputs.tf`**

Write to `modules/storage_account/outputs.tf`:

```hcl
output "id" {
  description = "ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "The primary blob service endpoint."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  description = "The primary access key of the storage account."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string of the storage account."
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}
```

- [ ] **Step 6: Write `.terraform-docs.yml`**

Write to `modules/storage_account/.terraform-docs.yml`:

```yaml
formatter: "md table"

version: ""

header-from: main.tf
footer-from: ""

sections:
  hide: []
  show: []

content: |-
  # Storage Account

  This module creates a general-purpose v2 Azure Storage Account. Secure by default: public access disabled, TLS 1.2 enforced, shared key access disabled.

  {{ .Header }}

  {{ .Inputs }}

  {{ .Outputs }}

  # Examples

  ## Default
  ```hcl
  {{ include "examples/default/main.tf" }}
  ```

output:
  file: "README.md"
  path: "."

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: false
  read-comments: true
  required: true
  sensitive: true
  type: true
```

- [ ] **Step 7: Write example files**

Write to `modules/storage_account/examples/default/provider.tf`:

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
provider "azurerm" {
  features {}
}
```

Write to `modules/storage_account/examples/default/main.tf`:

```hcl
module "storage_account" {
  # source = "github.com/crytlig/tfmods//modules/storage_account?ref=main"
  source = "../../"

  name                          = "stexample${random_string.example.result}"
  location                      = "westeurope"
  resource_group_name           = azurerm_resource_group.example.name
  public_network_access_enabled = true

  network_rules = {
    ip_rules = [local.ip]
  }

  blob_properties = {
    versioning_enabled    = true
    delete_retention_days = 14
  }

  tags = {
    environment = "dev"
  }
}

resource "random_string" "example" {
  length  = 8
  special = false
  upper   = false
}

data "http" "example" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  ip = chomp(data.http.example.response_body)
}

resource "azurerm_resource_group" "example" {
  name     = "rg-st-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
```

- [ ] **Step 8: Validate**

```bash
cd modules/storage_account
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

- [ ] **Step 9: Commit**

```bash
git restore --staged :/
git add "modules/storage_account"
git commit -m "feat(storage_account): add module" -- "modules/storage_account"
```

---

### Task 6: `container_registry`

**Files:**
- Create: `modules/container_registry/main.tf`
- Create: `modules/container_registry/variables.tf`
- Create: `modules/container_registry/outputs.tf`
- Create: `modules/container_registry/provider.tf`
- Create: `modules/container_registry/README.md`
- Create: `modules/container_registry/.terraform-docs.yml`
- Create: `modules/container_registry/examples/default/main.tf`
- Create: `modules/container_registry/examples/default/provider.tf`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p modules/container_registry/examples/default
touch modules/container_registry/README.md
```

- [ ] **Step 2: Write `provider.tf`**

Write to `modules/container_registry/provider.tf`:

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

- [ ] **Step 3: Write `variables.tf`**

Write to `modules/container_registry/variables.tf`:

```hcl
variable "name" {
  type        = string
  description = "The name of the Container Registry. Must be 5-50 characters, alphanumeric only."

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "The name must be between 5 and 50 characters long and can only contain alphanumeric characters."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where the resource will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "sku" {
  type        = string
  default     = "Standard"
  description = "The SKU tier of the Container Registry. Must be `Standard` or `Premium`."

  validation {
    condition     = contains(["Standard", "Premium"], var.sku)
    error_message = "The SKU must be either Standard or Premium. Basic is not supported."
  }
}

variable "admin_enabled" {
  type        = bool
  default     = false
  description = "Enable admin user. Defaults to false - use managed identity for authentication."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Allow public network access. Set to false with Premium SKU and private endpoints."
}

variable "network_rule_bypass_option" {
  type        = string
  default     = "AzureServices"
  description = "Allow trusted Azure services to bypass network rules."

  validation {
    condition     = contains(["AzureServices", "None"], var.network_rule_bypass_option)
    error_message = "The network_rule_bypass_option must be either AzureServices or None."
  }
}

variable "georeplications" {
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool, false)
  }))
  default     = []
  description = <<DESCRIPTION
A list of geo-replication locations for the Container Registry. Requires Premium SKU.

- `location` - The Azure region for the replica.
- `zone_redundancy_enabled` - (Optional) Enable zone redundancy for the replica. Defaults to false.
DESCRIPTION
}

variable "retention_policy_days" {
  type        = number
  default     = 7
  description = "The number of days to retain untagged manifests. Requires Premium SKU."

  validation {
    condition     = var.retention_policy_days >= 0
    error_message = "Retention policy days must be 0 or greater."
  }
}
```

- [ ] **Step 4: Write `main.tf`**

Write to `modules/container_registry/main.tf`:

```hcl
resource "azurerm_container_registry" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  network_rule_bypass_option    = var.network_rule_bypass_option
  tags                          = var.tags

  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
    }
  }

  dynamic "retention_policy" {
    for_each = var.sku == "Premium" ? { this = true } : {}
    content {
      days    = var.retention_policy_days
      enabled = true
    }
  }
}
```

- [ ] **Step 5: Write `outputs.tf`**

Write to `modules/container_registry/outputs.tf`:

```hcl
output "id" {
  description = "ID of the Container Registry."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Name of the Container Registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "The login server URL of the Container Registry."
  value       = azurerm_container_registry.this.login_server
}
```

- [ ] **Step 6: Write `.terraform-docs.yml`**

Write to `modules/container_registry/.terraform-docs.yml`:

```yaml
formatter: "md table"

version: ""

header-from: main.tf
footer-from: ""

sections:
  hide: []
  show: []

content: |-
  # Container Registry

  This module creates an Azure Container Registry. Standard SKU by default, no admin user, no Basic SKU.

  {{ .Header }}

  {{ .Inputs }}

  {{ .Outputs }}

  # Examples

  ## Default
  ```hcl
  {{ include "examples/default/main.tf" }}
  ```

output:
  file: "README.md"
  path: "."

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: false
  read-comments: true
  required: true
  sensitive: true
  type: true
```

- [ ] **Step 7: Write example files**

Write to `modules/container_registry/examples/default/provider.tf`:

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
provider "azurerm" {
  features {}
}
```

Write to `modules/container_registry/examples/default/main.tf`:

```hcl
module "container_registry" {
  # source = "github.com/crytlig/tfmods//modules/container_registry?ref=main"
  source = "../../"

  name                = "crexample${random_string.example.result}"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"

  tags = {
    environment = "dev"
  }
}

resource "random_string" "example" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "rg-cr-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
```

- [ ] **Step 8: Validate**

```bash
cd modules/container_registry
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

- [ ] **Step 9: Commit**

```bash
git restore --staged :/
git add "modules/container_registry"
git commit -m "feat(container_registry): add module" -- "modules/container_registry"
```

---

### Task 7: `postgresql_flexible_server`

**Files:**
- Create: `modules/postgresql_flexible_server/main.tf`
- Create: `modules/postgresql_flexible_server/variables.tf`
- Create: `modules/postgresql_flexible_server/outputs.tf`
- Create: `modules/postgresql_flexible_server/provider.tf`
- Create: `modules/postgresql_flexible_server/README.md`
- Create: `modules/postgresql_flexible_server/.terraform-docs.yml`
- Create: `modules/postgresql_flexible_server/examples/default/main.tf`
- Create: `modules/postgresql_flexible_server/examples/default/provider.tf`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p modules/postgresql_flexible_server/examples/default
touch modules/postgresql_flexible_server/README.md
```

- [ ] **Step 2: Write `provider.tf`**

Write to `modules/postgresql_flexible_server/provider.tf`:

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

- [ ] **Step 3: Write `variables.tf`**

Write to `modules/postgresql_flexible_server/variables.tf`:

```hcl
variable "name" {
  type        = string
  description = "The name of the PostgreSQL Flexible Server."

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.name))
    error_message = "The name must be between 3 and 63 characters long and can only contain lowercase letters, numbers and dashes."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where the resource will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "administrator_login" {
  type        = string
  description = "The administrator login for the PostgreSQL server."
}

variable "administrator_password" {
  type        = string
  description = "The administrator password for the PostgreSQL server."
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "sku_name" {
  type        = string
  default     = "B_Standard_B1ms"
  description = "The SKU name for the PostgreSQL Flexible Server (e.g., B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)."
}

variable "version" {
  type        = string
  default     = "16"
  description = "The version of PostgreSQL to use."

  validation {
    condition     = contains(["13", "14", "15", "16"], var.version)
    error_message = "The PostgreSQL version must be one of: 13, 14, 15, 16."
  }
}

variable "storage_mb" {
  type        = number
  default     = 32768
  description = "The maximum storage allowed for the PostgreSQL Flexible Server in MB."
}

variable "storage_tier" {
  type        = string
  default     = null
  description = "The storage tier for the PostgreSQL Flexible Server. Auto-selected when null."
}

variable "delegated_subnet_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The ID of the subnet to delegate to the PostgreSQL Flexible Server for private access.
When set, the server is deployed into the VNet with private networking.
Must be set together with `private_dns_zone_id`.
DESCRIPTION
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The ID of the Private DNS Zone for the PostgreSQL Flexible Server.
Required when `delegated_subnet_id` is set.
DESCRIPTION
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Enable public network access. Defaults to false (secure by default)."
}

variable "zone" {
  type        = string
  default     = null
  description = "The availability zone for the PostgreSQL Flexible Server."
}

variable "backup_retention_days" {
  type        = number
  default     = 7
  description = "The number of days to retain backups. Valid range is 7 to 35."

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention must be between 7 and 35 days."
  }
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  default     = false
  description = "Enable geo-redundant backups."
}

variable "high_availability" {
  type = object({
    mode                      = string
    standby_availability_zone = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
High availability configuration for the PostgreSQL Flexible Server.

- `mode` - The high availability mode. Possible values are `SameZone` and `ZoneRedundant`.
- `standby_availability_zone` - (Optional) The availability zone for the standby server.
DESCRIPTION

  validation {
    condition     = var.high_availability == null ? true : contains(["SameZone", "ZoneRedundant"], var.high_availability.mode)
    error_message = "The high availability mode must be either SameZone or ZoneRedundant."
  }
}

variable "maintenance_window" {
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default     = null
  description = <<DESCRIPTION
The preferred maintenance window for the PostgreSQL Flexible Server.

- `day_of_week` - (Optional) The day of the week (0 = Sunday). Defaults to 0.
- `start_hour` - (Optional) The start hour for the maintenance window. Defaults to 0.
- `start_minute` - (Optional) The start minute for the maintenance window. Defaults to 0.
DESCRIPTION
}

variable "firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of firewall rules for the PostgreSQL Flexible Server. Only applicable when public network access is enabled.
The map key is used as the firewall rule name.

- `start_ip_address` - The start IP address for the firewall rule.
- `end_ip_address` - The end IP address for the firewall rule.
DESCRIPTION
}

variable "authentication" {
  type = object({
    active_directory_auth_enabled = optional(bool, true)
    password_auth_enabled         = optional(bool, true)
    tenant_id                     = optional(string, null)
  })
  default     = {}
  description = <<DESCRIPTION
Authentication configuration for the PostgreSQL Flexible Server.

- `active_directory_auth_enabled` - (Optional) Enable Azure Active Directory authentication. Defaults to true.
- `password_auth_enabled` - (Optional) Enable password authentication. Defaults to true.
- `tenant_id` - (Optional) The tenant ID for Azure Active Directory authentication.
DESCRIPTION
  nullable    = false
}
```

- [ ] **Step 4: Write `main.tf`**

Write to `modules/postgresql_flexible_server/main.tf`:

```hcl
resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  sku_name                      = var.sku_name
  version                       = var.version
  storage_mb                    = var.storage_mb
  storage_tier                  = var.storage_tier
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = var.public_network_access_enabled
  zone                          = var.zone
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
  tags                          = var.tags

  authentication {
    active_directory_auth_enabled = var.authentication.active_directory_auth_enabled
    password_auth_enabled         = var.authentication.password_auth_enabled
    tenant_id                     = var.authentication.tenant_id
  }

  dynamic "high_availability" {
    for_each = var.high_availability != null ? { this = var.high_availability } : {}
    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = high_availability.value.standby_availability_zone
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? { this = var.maintenance_window } : {}
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each = var.firewall_rules

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}
```

- [ ] **Step 5: Write `outputs.tf`**

Write to `modules/postgresql_flexible_server/outputs.tf`:

```hcl
output "id" {
  description = "ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "name" {
  description = "Name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "fqdn" {
  description = "The fully qualified domain name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}
```

- [ ] **Step 6: Write `.terraform-docs.yml`**

Write to `modules/postgresql_flexible_server/.terraform-docs.yml`:

```yaml
formatter: "md table"

version: ""

header-from: main.tf
footer-from: ""

sections:
  hide: []
  show: []

content: |-
  # PostgreSQL Flexible Server

  This module creates an Azure Database for PostgreSQL Flexible Server. Private access by default via delegated subnet and private DNS zone.

  {{ .Header }}

  {{ .Inputs }}

  {{ .Outputs }}

  # Examples

  ## Default
  ```hcl
  {{ include "examples/default/main.tf" }}
  ```

output:
  file: "README.md"
  path: "."

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: false
  read-comments: true
  required: true
  sensitive: true
  type: true
```

- [ ] **Step 7: Write example files**

Write to `modules/postgresql_flexible_server/examples/default/provider.tf`:

```hcl
terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
provider "azurerm" {
  features {}
}
```

Write to `modules/postgresql_flexible_server/examples/default/main.tf`:

```hcl
module "postgresql_flexible_server" {
  # source = "github.com/crytlig/tfmods//modules/postgresql_flexible_server?ref=main"
  source = "../../"

  name                          = "psql-example"
  location                      = "westeurope"
  resource_group_name           = azurerm_resource_group.example.name
  administrator_login           = "psqladmin"
  administrator_password        = random_password.example.result
  public_network_access_enabled = true

  firewall_rules = {
    allow_azure = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  }

  tags = {
    environment = "dev"
  }
}

resource "random_password" "example" {
  length  = 24
  special = true
}

resource "azurerm_resource_group" "example" {
  name     = "rg-psql-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
```

- [ ] **Step 8: Validate**

```bash
cd modules/postgresql_flexible_server
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

- [ ] **Step 9: Commit**

```bash
git restore --staged :/
git add "modules/postgresql_flexible_server"
git commit -m "feat(postgresql_flexible_server): add module" -- "modules/postgresql_flexible_server"
```

---

### Task 8: `diagnostic_setting`

**Files:**
- Create: `modules/diagnostic_setting/main.tf`
- Create: `modules/diagnostic_setting/variables.tf`
- Create: `modules/diagnostic_setting/outputs.tf`
- Create: `modules/diagnostic_setting/provider.tf`
- Create: `modules/diagnostic_setting/README.md`
- Create: `modules/diagnostic_setting/.terraform-docs.yml`
- Create: `modules/diagnostic_setting/examples/default/main.tf`
- Create: `modules/diagnostic_setting/examples/default/provider.tf`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p modules/diagnostic_setting/examples/default
touch modules/diagnostic_setting/README.md
```

- [ ] **Step 2: Write `provider.tf`**

Write to `modules/diagnostic_setting/provider.tf`:

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

- [ ] **Step 3: Write `variables.tf`**

Write to `modules/diagnostic_setting/variables.tf`:

```hcl
variable "name" {
  type        = string
  description = "The name of the diagnostic setting."
}

variable "target_resource_id" {
  type        = string
  description = "The ID of the resource to attach the diagnostic setting to."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The ID of the Log Analytics Workspace to send diagnostics to."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "The ID of the Storage Account to send diagnostics to (for archival)."
}

variable "enabled_log_categories" {
  type        = set(string)
  default     = null
  description = "A set of log categories to enable. When null, all available log categories are enabled."
}

variable "metric_categories" {
  type        = set(string)
  default     = null
  description = "A set of metric categories to enable. When null, all available metric categories are enabled."
}

variable "log_analytics_destination_type" {
  type        = string
  default     = null
  description = "The destination type for Log Analytics. Possible values are `Dedicated` and `AzureDiagnostics`."

  validation {
    condition     = var.log_analytics_destination_type == null ? true : contains(["Dedicated", "AzureDiagnostics"], var.log_analytics_destination_type)
    error_message = "The log_analytics_destination_type must be either Dedicated or AzureDiagnostics."
  }
}
```

- [ ] **Step 4: Write `main.tf`**

Write to `modules/diagnostic_setting/main.tf`:

```hcl
data "azurerm_monitor_diagnostic_categories" "this" {
  resource_id = var.target_resource_id
}

locals {
  log_categories    = var.enabled_log_categories != null ? var.enabled_log_categories : data.azurerm_monitor_diagnostic_categories.this.log_category_types
  metric_categories = var.metric_categories != null ? var.metric_categories : data.azurerm_monitor_diagnostic_categories.this.metrics
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                           = var.name
  target_resource_id             = var.target_resource_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.storage_account_id
  log_analytics_destination_type = var.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = local.log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = local.metric_categories
    content {
      category = metric.value
    }
  }
}
```

- [ ] **Step 5: Write `outputs.tf`**

Write to `modules/diagnostic_setting/outputs.tf`:

```hcl
output "id" {
  description = "ID of the diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.this.id
}
```

- [ ] **Step 6: Write `.terraform-docs.yml`**

Write to `modules/diagnostic_setting/.terraform-docs.yml`:

```yaml
formatter: "md table"

version: ""

header-from: main.tf
footer-from: ""

sections:
  hide: []
  show: []

content: |-
  # Diagnostic Setting

  This module creates an Azure Monitor diagnostic setting that attaches to any resource by ID. Discovers available log and metric categories automatically.

  {{ .Header }}

  {{ .Inputs }}

  {{ .Outputs }}

  # Examples

  ## Default
  ```hcl
  {{ include "examples/default/main.tf" }}
  ```

output:
  file: "README.md"
  path: "."

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: false
  read-comments: true
  required: true
  sensitive: true
  type: true
```

- [ ] **Step 7: Write example files**

Write to `modules/diagnostic_setting/examples/default/provider.tf`:

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
provider "azurerm" {
  features {}
}
```

Write to `modules/diagnostic_setting/examples/default/main.tf`:

```hcl
module "diagnostic_setting" {
  # source = "github.com/crytlig/tfmods//modules/diagnostic_setting?ref=main"
  source = "../../"

  name                       = "diag-kv-example"
  target_resource_id         = azurerm_key_vault.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_resource_group" "example" {
  name     = "rg-diag-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}

data "azurerm_client_config" "example" {}

resource "azurerm_key_vault" "example" {
  name                       = "kv-diag-example"
  location                   = "westeurope"
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.example.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  tags = {
    environment = "dev"
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-diag-example"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = "dev"
  }
}
```

- [ ] **Step 8: Validate**

```bash
cd modules/diagnostic_setting
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

- [ ] **Step 9: Commit**

```bash
git restore --staged :/
git add "modules/diagnostic_setting"
git commit -m "feat(diagnostic_setting): add module" -- "modules/diagnostic_setting"
```

---

### Task 9: Generate docs and final validation

- [ ] **Step 1: Run terraform-docs for all new modules**

```bash
make docs
```

- [ ] **Step 2: Run terraform fmt across the entire repo**

```bash
terraform fmt -recursive
```

- [ ] **Step 3: Commit generated docs**

```bash
git restore --staged :/
git add "modules/log_analytics_workspace/README.md" "modules/application_insights/README.md" "modules/user_assigned_identity/README.md" "modules/app_service_plan/README.md" "modules/storage_account/README.md" "modules/container_registry/README.md" "modules/postgresql_flexible_server/README.md" "modules/diagnostic_setting/README.md"
git commit -m "docs: generate README for all new modules"
```

- [ ] **Step 4: Push branch**

```bash
git push -u origin feat/web-app-landing-zone
```
