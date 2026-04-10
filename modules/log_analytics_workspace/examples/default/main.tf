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
