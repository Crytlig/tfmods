module "postgresql_flexible_server" {
  # source = "github.com/crytlig/tfmods//modules/postgresql_flexible_server?ref=main"
  source = "../../"

  name                          = "psql-example"
  location                      = "westeurope"
  resource_group_name           = azurerm_resource_group.example.name
  administrator_login           = "psqladmin"
  administrator_password        = random_password.example.result
  public_network_access_enabled = true

  firewall_rules = {
    allow_azure = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  }

  tags = {
    environment = "dev"
  }
}

resource "random_password" "example" {
  length  = 24
  special = true
}

resource "azurerm_resource_group" "example" {
  name     = "rg-psql-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
