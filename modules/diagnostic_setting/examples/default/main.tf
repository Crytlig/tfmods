module "diagnostic_setting" {
  # source = "github.com/crytlig/tfmods//modules/diagnostic_setting?ref=main"
  source = "../../"

  name                       = "diag-kv-example"
  target_resource_id         = azurerm_key_vault.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_resource_group" "example" {
  name     = "rg-diag-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}

data "azurerm_client_config" "example" {}

resource "azurerm_key_vault" "example" {
  name                       = "kv-diag-example"
  location                   = "westeurope"
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.example.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  tags = {
    environment = "dev"
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-diag-example"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = "dev"
  }
}
