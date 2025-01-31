resource "azurerm_resource_group" "example" {
  name     = "example-worker-example"
  location = "northeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_user_assigned_identity" "example" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "example-managed-identity"
}

resource "random_integer" "example" {
  min = 10000
  max = 99999
}

data "http" "current_ip" {
  url = "https://ipv4.icanhazip.com"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                = "example-key-${random_integer.example.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
    ip_rules       = [data.http.current_ip.response_body]
  }
}

resource "time_rotating" "example" {
  rotation_months = 1
}

module "virtual_machine" {
  source = "../.."

  name                = "virtual-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  admin_username      = "exampleadm"
  managed_identity_id = azurerm_user_assigned_identity.example.id

  sku_size = "Standard_B2als_v2"
  os_disk = {
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 100
  }
  generate_ssh_key = {
    name                           = "example-ssh-key"
    expiration_date_length_in_days = 45
    content_type                   = "text/plain"
    not_before_date                = time_rotating.example.rfc3339
    key_vault_id                   = azurerm_key_vault.example.id
  }

  subnet_id = azurerm_subnet.example.id
}
