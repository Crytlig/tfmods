<!-- BEGIN_TF_DOCS -->



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the Linux web app | `string` | n/a | yes |
| <a name="input_app_registration_password"></a> [app\_registration\_password](#input\_app\_registration\_password) | The password for the app registration | `string` | `null` | no |
| <a name="input_app_service_plan_id"></a> [app\_service\_plan\_id](#input\_app\_service\_plan\_id) | The ID of the App Service Plan | `string` | n/a | yes |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | The client ID for Azure Active Directory authentication | `string` | `null` | no |
| <a name="input_container_registry_login_server"></a> [container\_registry\_login\_server](#input\_container\_registry\_login\_server) | The login server URL for the container registry | `string` | `null` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name of the Docker image | `string` | `null` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | The tag of the Docker image | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resources will be created | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | The port number for the application | `number` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The tenant ID for Azure Active Directory authentication | `string` | n/a | yes |
| <a name="input_user_assigned_identity_client_id"></a> [user\_assigned\_identity\_client\_id](#input\_user\_assigned\_identity\_client\_id) | The client ID of the user-assigned managed identity | `string` | `null` | no |
| <a name="input_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#input\_user\_assigned\_identity\_id) | The ID of the user-assigned managed identity | `string` | `null` | no |
| <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id) | The ID of the subnet in the virtual network | `string` | `null` | no |

## Outputs

No outputs.

# Examples

## Default 
```hcl

```
<!-- END_TF_DOCS -->