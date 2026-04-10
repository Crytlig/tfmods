<!-- BEGIN_TF_DOCS -->
# Log Analytics Workspace

This module creates an Azure Log Analytics Workspace with configurable retention and ingestion quotas.



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_daily_quota_gb"></a> [daily\_quota\_gb](#input\_daily\_quota\_gb) | The daily ingestion quota in GB. Null means unlimited. | `number` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the workspace will be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Log Analytics Workspace. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | The number of days to retain data. Valid range is 30 to 730. | `number` | `30` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU (pricing tier) of the Log Analytics Workspace. | `string` | `"PerGB2018"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the Log Analytics Workspace. |
| <a name="output_primary_shared_key"></a> [primary\_shared\_key](#output\_primary\_shared\_key) | The primary shared key of the Log Analytics Workspace. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The unique workspace GUID. |

# Examples

## Default
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
<!-- END_TF_DOCS -->