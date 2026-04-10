<!-- BEGIN_TF_DOCS -->
# Storage Account

This module creates a general-purpose v2 Azure Storage Account. Secure by default: public access disabled, TLS 1.2 enforced, shared key access disabled.



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | The kind of storage account. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | The replication type of the storage account. | `string` | `"LRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | The tier of the storage account. | `string` | `"Standard"` | no |
| <a name="input_allow_nested_items_to_be_public"></a> [allow\_nested\_items\_to\_be\_public](#input\_allow\_nested\_items\_to\_be\_public) | Allow or disallow nested items within this account to opt into being public. | `bool` | `false` | no |
| <a name="input_blob_properties"></a> [blob\_properties](#input\_blob\_properties) | Blob service properties for the storage account. When null, defaults are used.<br/><br/>- `versioning_enabled` - (Optional) Enable blob versioning. Defaults to false.<br/>- `delete_retention_days` - (Optional) Days to retain deleted blobs. Defaults to 7.<br/>- `container_delete_retention_days` - (Optional) Days to retain deleted containers. Defaults to 7.<br/>- `cors_rule` - (Optional) CORS rules for blob service. | <pre>object({<br/>    versioning_enabled              = optional(bool, false)<br/>    delete_retention_days           = optional(number, 7)<br/>    container_delete_retention_days = optional(number, 7)<br/>    cors_rule = optional(list(object({<br/>      allowed_headers    = list(string)<br/>      allowed_methods    = list(string)<br/>      allowed_origins    = list(string)<br/>      exposed_headers    = list(string)<br/>      max_age_in_seconds = number<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resource will be created. | `string` | n/a | yes |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | The minimum supported TLS version. | `string` | `"TLS1_2"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the storage account. Must be 3-24 characters, lowercase letters and numbers only. | `string` | n/a | yes |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | Network ACL rules for the storage account. When null, no explicit network rules are set.<br/><br/>- `default_action` - (Optional) The default action when no rule matches. Defaults to `Deny`.<br/>- `bypass` - (Optional) Services allowed to bypass the rules. Defaults to `["AzureServices"]`.<br/>- `ip_rules` - (Optional) List of IP CIDR ranges to allow.<br/>- `virtual_network_subnet_ids` - (Optional) List of subnet IDs to allow. | <pre>object({<br/>    default_action             = optional(string, "Deny")<br/>    bypass                     = optional(set(string), ["AzureServices"])<br/>    ip_rules                   = optional(list(string), [])<br/>    virtual_network_subnet_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Allow public network access to the storage account. Defaults to false (secure by default). | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#input\_shared\_access\_key\_enabled) | Enable shared key authorization. Defaults to false - use Entra ID (RBAC) instead. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the storage account. |
| <a name="output_name"></a> [name](#output\_name) | Name of the storage account. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key of the storage account. |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob service endpoint. |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The primary connection string of the storage account. |

# Examples

## Default
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
<!-- END_TF_DOCS -->