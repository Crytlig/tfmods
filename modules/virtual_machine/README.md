<!-- BEGIN_TF_DOCS -->



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | (Optional) Admin username. Defaults to adminjensen | `string` | `"adminjensen"` | no |
| <a name="input_enable_public_ip"></a> [enable\_public\_ip](#input\_enable\_public\_ip) | (Optional) Enable public IP resource creation. Defaults to true | `bool` | `true` | no |
| <a name="input_generate_ssh_key"></a> [generate\_ssh\_key](#input\_generate\_ssh\_key) | For simplicity this module provides the option to use an auto-generated SSH key. That password or key is then stored in a key vault. <br><br>- `name` - (Optional) - The name to use for the key vault secret that stores the auto-generated ssh key or password<br>- `expiration_date_length_in_days` - (Optional) - This value sets the number of days from the installation date to set the key vault expiration value. It defaults to `45` days.  This value will not be overridden in subsequent runs. If you need to maintain this virtual machine resource for a long period, generate and/or use your own password or ssh key.<br>- `content_type` - (Optional) - This value sets the secret content type.  Defaults to `text/plain`<br>- `not_before_date` - (Optional) - The UTC datetime (Y-m-d'T'H:M:S'Z) date before which this key is not valid.  Defaults to null.<br>- `key_vault_id` - (Optional) - key vault ID to store the generated SSH key in<br>- `tags` - (Optional) - Specific tags to assign to this secret resource | <pre>object({<br>    name                           = optional(string, null)<br>    expiration_date_length_in_days = optional(number, 45)<br>    content_type                   = optional(string, "text/plain")<br>    not_before_date                = optional(string, null)<br>    key_vault_id                   = optional(string, null)<br>    tags                           = optional(map(string), {})<br>  })</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where this and supporting resources should be deployed. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name to use when creating the virtual machine. | `string` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The Public Key which should be used for authentication, which needs to be at least 2048-bit and in ssh-rsa format. Changing this forces a new resource to be created.<br>Public key takes precedence over generate\_ssh\_key | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group name of the resource group where the vm resources will be deployed. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The sku value to use for this virtual machine | `string` | `"Standard_B1ms"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet id to attach network interface to | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to be assigned to this resource | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_nic_id"></a> [nic\_id](#output\_nic\_id) | n/a |

# Examples

## Default
```hcl

```
<!-- END_TF_DOCS -->