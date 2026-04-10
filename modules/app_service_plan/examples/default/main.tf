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
