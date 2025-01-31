<!-- BEGIN_TF_DOCS -->



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | Address space of the virtual network. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | A datacenter location in Azure. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the virtual network. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional tags for the resource group. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |

# Examples

## Default 
```hcl

```
<!-- END_TF_DOCS -->