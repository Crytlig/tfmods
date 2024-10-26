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
}
