module "storage_account" {
  # source = "github.com/crytlig/tfmods//modules/storage_account?ref=main"
  source = "../../"

  name                          = "stexample${random_string.example.result}"
  location                      = "westeurope"
  resource_group_name           = azurerm_resource_group.example.name
  public_network_access_enabled = true

  network_rules = {
    ip_rules = [local.ip]
  }

  blob_properties = {
    versioning_enabled    = true
    delete_retention_days = 14
  }

  tags = {
    environment = "dev"
  }
}

resource "random_string" "example" {
  length  = 8
  special = false
  upper   = false
}

data "http" "example" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  ip = chomp(data.http.example.response_body)
}

resource "azurerm_resource_group" "example" {
  name     = "rg-st-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
