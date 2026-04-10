module "container_registry" {
  # source = "github.com/crytlig/tfmods//modules/container_registry?ref=main"
  source = "../../"

  name                = "crexample${random_string.example.result}"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"

  tags = {
    environment = "dev"
  }
}

resource "random_string" "example" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "rg-cr-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
