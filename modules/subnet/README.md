<!-- BEGIN_TF_DOCS -->



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_prefixes"></a> [address\_prefixes](#input\_address\_prefixes) | The address prefix to use for the subnet. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of Azure Datacenter | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the subnet. | `string` | n/a | yes |
| <a name="input_network_security_group_id"></a> [network\_security\_group\_id](#input\_network\_security\_group\_id) | The ID of the network security group which should be associated with the subnet. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | The ID of the route table which should be associated with the subnet. | `string` | `null` | no |
| <a name="input_service_delegation"></a> [service\_delegation](#input\_service\_delegation) | The name of service to delegate to. | `string` | `null` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The list of Service endpoints to associate with the subnet. | `set(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional tags for the resource group. | `map(any)` | `null` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the virtual network. | `string` | n/a | yes |

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