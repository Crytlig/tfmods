<!-- BEGIN_TF_DOCS -->



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the vault. | `bool` | `false` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | Specifies whether Azure Resource Manager is permitted to retrieve secrets from the vault. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Key Vault. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | The network ACL configuration for the Key Vault.<br>If not specified then the Key Vault will be created with a firewall that blocks access.<br>Specify `null` to create the Key Vault with no firewall.<br><br>- `bypass` - (Optional) Should Azure Services bypass the ACL. Possible values are `AzureServices` and `None`. Defaults to `AzureServices`.<br>- `default_action` - (Optional) The default action when no rule matches. Possible values are `Allow` and `Deny`. Defaults to `Deny`.<br>- `ip_rules` - A list of IP rules in CIDR format.<br>- `virtual_network_subnet_ids` - (Optional) When using with Service Endpoints, a list of subnet IDs to associate with the Key Vault. Defaults to `[]`. | <pre>object({<br>    bypass                     = optional(string, "AzureServices")<br>    default_action             = optional(string, "Deny")<br>    ip_rules                   = list(string)<br>    virtual_network_subnet_ids = optional(list(string), [])<br>  })</pre> | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Specifies whether public access is permitted. Defaults to true<br>Key vault requires network ACLs so only permitted IPs are allowed.<br>When using Private endpoint, public\_network\_access\_enabled should probably be set to false. | `bool` | `false` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | (Optional) Specifies whether protection against purge is enabled for this Key Vault. Defaults to false. Note once enabled this cannot be disabled. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | A map of role assignments to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br><br>- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.<br>- `principal_id` - The ID of the principal to assign the role to.<br>- `description` - The description of the role assignment.<br>- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.<br>- `condition` - The condition which will be used to scope the role assignment.<br>- `condition_version` - The version of the condition syntax. If you are using a condition, valid values are '2.0'.<br><br>> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal. | <pre>map(object({<br>    role_definition_id_or_name             = string<br>    principal_id                           = string<br>    description                            = optional(string, null)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>    condition                              = optional(string, null)<br>    condition_version                      = optional(string, null)<br>    delegated_managed_identity_resource_id = optional(string, null)<br>  }))</pre> | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name of the Key Vault. Default is `standard`. `Possible values are `standard` and `premium`.` | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the Key Vault resource. | `map(any)` | n/a | yes |
| <a name="input_wait_for_rbac"></a> [wait\_for\_rbac](#input\_wait\_for\_rbac) | This variable controls the amount of time to wait before performing secret operations.<br>It only applies when `var.role_assignments` is set.<br>This is useful when you are creating role assignments on the key vault and immediately creating secrets in it<br>The default is 30 seconds for create and 0 seconds for destroy. | <pre>object({<br>    create  = optional(string, "30s")<br>    destroy = optional(string, "0s")<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the key vault. |

# Examples

## Default
```hcl
# Key vault module. Public access is denied by default
module "key_vault" {
  # source  = "github.com/crytlig/tfmods//modules/key_vault?ref=main"
  source = "../../"

  name                = replace("kvexample${random_pet.example.id}", "-", "")
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  # Public network access has to be enabled for network ACLs
  # when using a private endpoint, this should be disabled - which it is by default
  public_network_access_enabled = true

  network_acls = {
    virtual_network_subnet_ids = [azurerm_subnet.example.id]
    ip_rules                   = [local.ip]
  }

  role_assignments = {
    client_kv_secrets_officer = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azuread_client_config.example.object_id
      description                = "Example role assignment for the deployment client"
      principal_type             = "User"
    }
  }

  # Wait for rbac propagation
  wait_for_rbac = {
    create  = "30s"
    destroy = "0s"
  }

  tags = {
    environment = "dev"
  }
}

############################################
################  Dependencies #############
############################################
data "azuread_client_config" "example" {}

data "http" "example" {
  url = "https://ipv4.icanhazip.com"
}

resource "random_pet" "example" {
  length = 2
}

locals {
  ip = "${chomp(data.http.example.response_body)}/32"
}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-kv-example"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.250.0.0/26"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "example" {
  name                 = "snet-kv-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.250.0.0/29"]
  service_endpoints    = ["Microsoft.KeyVault"]
}
```
<!-- END_TF_DOCS -->