<!-- BEGIN_TF_DOCS -->



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | A datacenter location in Azure. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the resource group. | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_location"></a> [location](#output\_location) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |

# Examples

## Default
```hcl
module "resource_group" {
  source = "../"

  name = "rg-workload"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
```
<!-- END_TF_DOCS -->
