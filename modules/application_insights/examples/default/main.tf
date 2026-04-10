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
