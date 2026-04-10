<!-- BEGIN_TF_DOCS -->
# Application Insights

This module creates a workspace-based Azure Application Insights instance linked to a Log Analytics Workspace.



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | The type of Application Insights to create. | `string` | `"web"` | no |
| <a name="input_daily_data_cap_in_gb"></a> [daily\_data\_cap\_in\_gb](#input\_daily\_data\_cap\_in\_gb) | The daily data volume cap in GB. Null means no cap. | `number` | `null` | no |
| <a name="input_disable_ip_masking"></a> [disable\_ip\_masking](#input\_disable\_ip\_masking) | Disable IP masking in logs. When false (default), client IPs are masked. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resource will be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Application Insights instance. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | The number of days to retain data. | `number` | `90` | no |
| <a name="input_sampling_percentage"></a> [sampling\_percentage](#input\_sampling\_percentage) | The percentage of telemetry items to sample (0-100). | `number` | `100` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | The ID of the Log Analytics Workspace to link to. Required for workspace-based Application Insights. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | The application ID of the Application Insights instance. |
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | The connection string of the Application Insights instance. |
| <a name="output_id"></a> [id](#output\_id) | ID of the Application Insights instance. |
| <a name="output_instrumentation_key"></a> [instrumentation\_key](#output\_instrumentation\_key) | The instrumentation key of the Application Insights instance. |

# Examples

## Default
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
<!-- END_TF_DOCS -->