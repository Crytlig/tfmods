<!-- BEGIN_TF_DOCS -->
# Coolify worker module

This is a module for deploying a coolify worker (VM) including a network security group, public ip address etc.



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | admin username used for ssh | `string` | n/a | yes |
| <a name="input_coolify_manager_ip"></a> [coolify\_manager\_ip](#input\_coolify\_manager\_ip) | IP address of the Coolify manager instance | `string` | n/a | yes |
| <a name="input_create_public_ip"></a> [create\_public\_ip](#input\_create\_public\_ip) | Whether to create and associate a public IP address | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be deployed | `string` | n/a | yes |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id) | The ID of the managed identity to be used with Azure resources | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to be used for the machine that will be created | `string` | n/a | yes |
| <a name="input_network_security_group_name"></a> [network\_security\_group\_name](#input\_network\_security\_group\_name) | Name of the network security group to be associated with resources | `string` | n/a | yes |
| <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk) | n/a | <pre>object({<br>    storage_account_type = string<br>    disk_size_gb         = number<br>    caching              = string<br>  })</pre> | <pre>{<br>  "caching": "ReadWrite",<br>  "disk_size_gb": 50,<br>  "storage_account_type": "Standard_LRS"<br>}</pre> | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Azure resource group where resources will be deployed | `string` | n/a | yes |
| <a name="input_sku_size"></a> [sku\_size](#input\_sku\_size) | The SKU size for the virtual machine | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key for secure access to resources | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet where resources will be deployed | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_network_security_group_id"></a> [network\_security\_group\_id](#output\_network\_security\_group\_id) | n/a |
| <a name="output_network_security_group_location"></a> [network\_security\_group\_location](#output\_network\_security\_group\_location) | n/a |
| <a name="output_network_security_group_name"></a> [network\_security\_group\_name](#output\_network\_security\_group\_name) | n/a |
| <a name="output_network_security_group_resource_group_name"></a> [network\_security\_group\_resource\_group\_name](#output\_network\_security\_group\_resource\_group\_name) | n/a |
| <a name="output_network_security_group_security_rules"></a> [network\_security\_group\_security\_rules](#output\_network\_security\_group\_security\_rules) | n/a |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | n/a |

# Examples

## Default
```hcl
resource "azurerm_resource_group" "example" {
  name     = "cooli-worker-example"
  location = "northeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "cooli-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "cooli-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_user_assigned_identity" "example" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "cooli-managed-identity"
}

module "cooli" {
  source = "../.."

  name                = "cooli"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  admin_username              = "cooli"
  coolify_manager_ip          = "10.10.10.10" # Used for SSH access
  managed_identity_id         = azurerm_user_assigned_identity.example.id
  network_security_group_name = "example-nsg"
  sku_size                    = "Standard_B2als_v2"
  ssh_public_key              = file("~/.ssh/azure_vms.pub")
  subnet_id                   = azurerm_subnet.example.id
  os_disk = {
    storage_account_type = "Standard_LRS",
  disk_size_gb = 50 }
}
```
<!-- END_TF_DOCS -->
