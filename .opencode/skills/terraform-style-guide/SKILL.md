--
name: terraform-style-guide
description: Use when writing, reviewing, or generating Terraform HCL code targeting Azure (azurerm). Enforces naming, file layout, variable, output, module, and resource ordering conventions.
--

# Terraform Style Guide (Azure)

Generate and maintain Terraform code following HashiCorp's style conventions, adapted for Azure (`azurerm`) with project-specific best practices.

**Reference:** [HashiCorp Terraform Style Guide](https://developer.hashicorp.com/terraform/language/style)

## Code Generation Strategy

When generating Terraform code:

1. Start with provider configuration and version constraints
2. Create data sources before dependent resources
3. Build resources in dependency order
4. Add outputs for key resource attributes
5. Use variables for all configurable values

## File Organization

| File           | Purpose                                                     |
| -------------- | ----------------------------------------------------------- |
| `main.tf`      | Resources, data sources, and ephemeral resources            |
| `variables.tf` | Input variable declarations (required first, then optional) |
| `outputs.tf`   | Output value declarations                                   |
| `providers.tf` | Terraform & Provider configurations and version constraints |
| `locals.tf`    | Local value declarations (optional)                         |

**Module-level `terraform.tf`** declares version constraints only - never include a `provider` block in the module itself. The `provider "azurerm" {}` block belongs only in `examples/*/provider.tf`.

### Example Structure

```hcl
# terraform.tf
terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  # optionally backend (for examples)
  # or for module consumption
}

# providers.tf
provider "azurerm" {
  features {}
}

# variables.tf
variable "name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for deployment"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to all resources"
  default     = {}
}

# main.tf
resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location

  tags = var.tags
}

# outputs.tf
output "id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}
```

## Code Formatting

### Indentation and Alignment

- Use **two spaces** per nesting level (no tabs)
- Align equals signs for consecutive single-line arguments within a block
- Separate groups of single-line arguments from block arguments with a blank line

```hcl
resource "azurerm_virtual_network" "this" {
  name                = "vnet-example-weu"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/24"]

  tags = var.tags
}
```

### Block Organization Within a Resource

Arguments precede blocks, with meta-arguments first. Follow this order:

1. `count` or `for_each` meta-argument
2. Single-line arguments (grouped, aligned `=`)
3. Block arguments (dynamic, delegation, etc.)
4. `tags` argument
5. `depends_on`
6. `lifecycle` block (always last)

**Good:**

```hcl
resource "azurerm_subnet" "container_instance" {
  count = var.deploy_aci ? 1 : 0

  name                 = "container-instance"
  resource_group_name  = azurerm_virtual_network.this.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.0.0/29"]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}
```

**Bad** - meta-argument buried in the middle, blocks before arguments, no alignment, no spacing between resources:

```hcl
resource "azurerm_subnet" "subnet1" {
  resource_group_name  = azurerm_virtual_network.main.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  count = var.deploy_aci ? 1 : 0
  address_prefixes     = ["10.0.0.0/29"]
  name                 = "container-instances"
  tags = {
    Team = "Spirit"
  }
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
resource "azurerm_subnet" "subnet2" {
  name = "container-instances"
  resource_group_name = azurerm_virtual_network.main.resource_group_name
  address_prefixes     = ["10.0.0.8/29"]
  tags = {
    Team = "Spirit"
  }
  virtual_network_name = azurerm_virtual_network.main.name
}
```

### Source Type Ordering in main.tf

Place data sources first, then resources, then ephemeral resources:

```hcl
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = var.address_space

  tags = var.tags
}

ephemeral "azurerm_key_vault_secret" "this" {
  name         = "connection-string"
  key_vault_id = var.key_vault_id
}
```

## Naming Conventions

- Use **lowercase with underscores** for all Terraform names (resources, variables, outputs, locals)
- Use **hyphens** for Azure resource names (the `name` argument value)
- Resource names must be **singular**, not plural
- Be **specific and meaningful** - do not repeat the resource type in the symbolic name. Default to using `main` for resources where a descriptive name is redundant or unavailable, provided only one instance exists

### Stacks vs Modules: `main` vs `this`

- In a **stack/composition** (root-level deployment), use `main` for the primary resource of each type
- In a **module**, use `this` for the primary resource

This distinction signals to the reader whether they are looking at a module or a stack.

**Good** (in a stack):

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-cpt-example-weu"
  location = "westeurope"
}

resource "azurerm_container_registry" "main" {
  name                = "crcptexampleweu"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"

  tags = var.tags
}
```

**Good** (in a module):

```hcl
resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  tags = var.tags
}
```

**Bad** - repeats the resource type in the symbolic name:

```hcl
resource "azurerm_resource_group" "resource_group" {}
resource "azurerm_container_registry" "container_registry" {}
resource "azurerm_application_insights" "app_insights" {}
```

**Bad** - uses `main` inside a module:

```hcl
# Inside a module - should be "this"
resource "azurerm_application_insights" "main" {}
```

### Multiple Resources of the Same Type

When a stack has multiple resources of the same type, use descriptive names to differentiate:

**Good:**

```hcl
resource "azurerm_resource_group" "weu" {
  name     = var.weu_resource_group_name
  location = "westeurope"
}

resource "azurerm_resource_group" "neu" {
  name     = var.neu_resource_group_name
  location = "northeurope"
}
```

**Bad** - inconsistent naming, generic `resource_group_name` is ambiguous when there are multiple:

```hcl
resource "azurerm_resource_group" "weu" {
  name     = var.resource_group_name  # Which one?
  location = "westeurope"
}

resource "azurerm_resource_group" "neu" {
  name     = var.neu_resource_group_name
  location = "northeurope"
}
```

### Casing Summary

```hcl
# Underscore for Terraform identifiers
resource "azurerm_resource_group" "main" {
  # Hyphen for Azure resource name values
  name     = "rg-cpt-example-weu"
  location = "westeurope"
}
```

**Bad** - mixed casing and wrong separators:

```hcl
resource "azurerm_resource_group" "resource-Group" {
  name     = "rg-cpt-example_weu"
  location = "westeurope"
}
```

## Variables

### General Rules

- Declare all variables in `variables.tf`
- Sort variables: **required first**, then optional (with defaults)
- Every variable must have `type` and `description`
- Use `validation` blocks for input constraints
- Use HEREDOC (`<<DESCRIPTION ... DESCRIPTION`) for long descriptions
- Use `optional()` with defaults inside object types
- Mark sensitive variables with `sensitive = true`
- Set `nullable = false` for variables that must never be null
- Prefer positive names for booleans (e.g., `enable_monitoring` not `disable_monitoring`)
- Use plural form for `list(...)` or `map(...)` types
- Don't abbreviate - match provider naming (e.g., `resource_group_name` not `rg_name`)

### Key Order Within a Variable Block

1. `type`
2. `description`
3. `default` (optional)
4. `sensitive` (optional)
5. `nullable` (optional)
6. `validation` blocks (optional)

### Variable Naming

Variable names should include the resource type, matching the provider's own naming to avoid confusion, unless we deem the provider's naming insufficient.

**Good:**

```hcl
variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group"
}

variable "network_security_group_name" {
  type        = string
  description = "Name of the network security group"
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the virtual network"
}
```

**Bad** - abbreviated names lose clarity:

```hcl
variable "rg_name" {
  type        = string
  description = "Name of the Azure resource group"
}

variable "nsg_name" {
  type        = string
  description = "Name of the network security group"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}
```

An example of where the provider's example is less than optimal (in my opinion):

```hcl
resource "azurerm_linux_web_app" "example" {
  name                = "example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example.location
  service_plan_id     = azurerm_service_plan.example.id

  virtual_network_subnet_id = "some-id" # description from provider:
  # virtual_network_subnet_id - (Optional) The subnet id which will be used by this Web App for regional virtual network integration.


  site_config {}
}
```

The subnet is funky in web apps, as the app service plan and web app will need two subnets.
One for inbound and one for outbound. This particular input, `virtual_network_subnet_id`,
is for the outbound subnet. A better naming in this case would be: `outbound_virtual_network_subnet_id`.

### Module Variables

For modules, use shorter names without the resource type prefix, since the module context makes it clear:

```hcl
# In a key_vault module
variable "name" {
  type        = string
  description = "Name of the Key Vault"
}

variable "location" {
  type        = string
  description = "Azure region for the Key Vault"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into"
}
```

### Variable Validation

Use validation to close the feedback loop - `terraform plan` will fail early instead of failing on `apply`:

```hcl
variable "subresource_name" {
  type        = string
  description = <<DESCRIPTION
    The subresource name for the private endpoint.
    See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
  DESCRIPTION

  validation {
    condition     = contains(["registry", "sites", "blob", "file", "sql", "mysqlServer", "postgresqlServer", "namespace", "vault"], var.subresource_name)
    error_message = <<-EOF
      ${var.subresource_name} does not match any pre-existing private DNS zones.
      Please contact the platform team if you need a new DNS zone created
      or double-check the documentation if you entered the value correctly.
    EOF
  }
}

variable "sku_name" {
  type        = string
  description = "The SKU name for the Key Vault"
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU name must be 'standard' or 'premium'."
  }
}
```

## Outputs

### General Rules

- Every output must have a `description`
- At minimum, expose the `id` of the primary resource
- Output through resources, even when the value matches a variable input
- Prefer key order: `description`, `value`, `sensitive`
- In modules, use the provider's output name (e.g., `name`, `id`, `location`)
- In stacks/compositions, prefix with the resource type (e.g., `virtual_network_name`)
- Never pass through the whole resource object from a module

**Good** (module outputs - short names, through resources):

```hcl
output "id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "location" {
  description = "The location of the virtual network"
  value       = azurerm_virtual_network.this.location
}
```

**Good** (composition outputs - prefixed names):

```hcl
output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.main.name
}
```

**Bad** - direct passthrough of variable instead of resource attribute:

```hcl
output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = var.virtual_network_name
}
```

**Bad** - abbreviated output name in a module:

```hcl
output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.this.name
}
```

**Bad** - passing through the whole resource object:

```hcl
output "virtual_network" {
  description = "Virtual network object"
  value       = azurerm_virtual_network.this
}
```

## Dynamic Resource Creation

### count for Conditional Creation

```hcl
resource "azurerm_private_endpoint" "this" {
  count = var.private_endpoint == null ? 0 : 1

  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id

  tags = var.tags
}
```

### for_each for Named Collections

```hcl
variable "subnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
  description = "Map of subnet names to their configuration"
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = azurerm_virtual_network.this.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}
```

### Dynamic Blocks for Optional Configuration

```hcl
resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}
```

## Module Conventions

### Directory Structure

Every module must include:

```
modules/<module_name>/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf            # required_version + required_providers ONLY
├── README.md              # Auto-generated by terraform-docs
├── .terraform-docs.yml
├── examples/
│   └── default/
│       ├── main.tf
│       └── providers.tf    # Contains provider "azurerm" { features {} }
└── tests/                 # Optional but recommended
    ├── default.tftest.hcl
    └── setup/
        └── main.tf
```

### Module Design Principles

- Secure by design - private networking, encryption on by default
- Expose only the minimum necessary inputs
- Tie related resources together so the consumer doesn't have to (e.g., private endpoint alongside the main resource)
- Use `this` for the primary resource of each type

### Module Testing

- A `default.tftest.hcl` file should test the module with only required variables (all defaults)
- Avoid using other modules from the repository in tests - isolate behavior
- Test **logic and behavior**, not that inputs match outputs with no logic

**Good** - tests a validation rule:

```hcl
# Module variable
variable "name" {
  type        = string
  description = "Name of the NSG resource. Must start with 'nsg-'"

  validation {
    condition     = startswith(var.name, "nsg-")
    error_message = "The name should start with 'nsg-'"
  }
}

# Test in tests/default.tftest.hcl
run "invalid_nsg_name" {
  command = plan

  variables {
    name = "bad-name-here"
  }

  expect_failures = [
    var.name
  ]
}
```

**Bad** - tests that an input equals an output (no logic):

```hcl
variable "resource_group_name" {
  type        = string
  description = "Name of Azure resource group"
}

# Test
run "valid_resource_group_name" {
  assert {
    condition     = azurerm_network_security_group.this.resource_group_name == var.resource_group_name
    error_message = "resource_group_name should match ${var.resource_group_name}"
  }
}
```

## Security Best Practices

When generating Azure resources, apply security hardening:

- Enable encryption at rest by default (Key Vault keys, storage encryption)
- Configure private networking where applicable (private endpoints, service endpoints)
- Apply principle of least privilege for NSG rules and RBAC role assignments
- Enable diagnostic settings and logging
- Never hardcode credentials or secrets
- Mark sensitive outputs with `sensitive = true`
- Resources are not available on the internet unless specifically designed to be

## Version Pinning

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

**Version constraint operators:**

- `= 1.0.0` - Exact version
- `>= 1.0.0` - Greater than or equal
- `~> 1.0` - Allow rightmost component to increment
- `>= 1.0, < 2.0` - Version range

## Provider Configuration

Provider blocks belong only in example or root-level deployments, never in modules:

```hcl
# examples/default/provider.tf
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

## Version Control

**Never commit:**

- `terraform.tfstate`, `terraform.tfstate.backup`
- `.terraform/` directory
- `*.tfplan`
- `*.auto.tfvars`

**Always commit:**

- All `.tf` configuration files
- `.terraform.lock.hcl` (dependency lock file)

## Validation Tools

Run before committing:

```bash
terraform fmt -recursive
terraform validate
tflint -init && tflint
```

## Code Review Checklist

- [ ] Code formatted with `terraform fmt`
- [ ] Configuration validated with `terraform validate`
- [ ] Files organized according to standard structure
- [ ] All variables have `type` and `description`
- [ ] All outputs have `description`
- [ ] Resource names follow `main`/`this` convention
- [ ] No abbreviated variable names - match provider naming
- [ ] Version constraints pinned explicitly
- [ ] Sensitive values marked with `sensitive = true`
- [ ] No hardcoded credentials or secrets
- [ ] All taggable resources include `tags`
- [ ] Outputs reference resource attributes, not variable passthroughs
- [ ] Module outputs use provider-standard names (`id`, `name`, `location`)
- [ ] `provider` blocks only exist in examples, not in modules
