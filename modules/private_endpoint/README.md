<!-- BEGIN_TF_DOCS -->



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_manual_connection"></a> [is\_manual\_connection](#input\_is\_manual\_connection) | Specifies whether the connection must be approved manually | `bool` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | A datacenter location in Azure. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Private Endpoint | `string` | n/a | yes |
| <a name="input_private_connection_name"></a> [private\_connection\_name](#input\_private\_connection\_name) | The name of the private connection name | `string` | n/a | yes |
| <a name="input_private_connection_request_message"></a> [private\_connection\_request\_message](#input\_private\_connection\_request\_message) | The message sent with manual connection request. Relevant only for manual connections | `string` | `null` | no |
| <a name="input_private_connection_resource_id"></a> [private\_connection\_resource\_id](#input\_private\_connection\_resource\_id) | The ID of the resource where the connection should be made to. | `string` | n/a | yes |
| <a name="input_private_connection_subresource_names"></a> [private\_connection\_subresource\_names](#input\_private\_connection\_subresource\_names) | The subresource names of the resource where the connection should be made to. | `set(string)` | n/a | yes |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | The name of the private DNS zone group. | `string` | `"deployedByPolicy"` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | The IDs of the private DNS zones. | `set(string)` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The Id of the subnet | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional tags for the resource group. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_dns_configs"></a> [custom\_dns\_configs](#output\_custom\_dns\_configs) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_network_interface"></a> [network\_interface](#output\_network\_interface) | n/a |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |

# Examples

## Default 
```hcl

```
<!-- END_TF_DOCS -->