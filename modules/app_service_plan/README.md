<!-- BEGIN_TF_DOCS -->
# App Service Plan

This module creates an Azure App Service Plan for hosting web apps, APIs, and functions.



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resource will be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the App Service Plan. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU for the App Service Plan (e.g., B1, S1, P1v3). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | n/a | yes |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | The number of workers (instances) to allocate. | `number` | `null` | no |
| <a name="input_zone_balancing_enabled"></a> [zone\_balancing\_enabled](#input\_zone\_balancing\_enabled) | Should workers be distributed across availability zones. Requires a zone-redundant SKU. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the App Service Plan. |
| <a name="output_kind"></a> [kind](#output\_kind) | The kind value of the App Service Plan. |
| <a name="output_name"></a> [name](#output\_name) | Name of the App Service Plan. |
| <a name="output_os_type"></a> [os\_type](#output\_os\_type) | The OS type of the App Service Plan. |

# Examples

## Default
```hcl
module "app_service_plan" {
  # source = "github.com/crytlig/tfmods//modules/app_service_plan?ref=main"
  source = "../../"

  name                = "asp-example"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "B1"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "rg-asp-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
```
<!-- END_TF_DOCS -->