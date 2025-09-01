# terraform {
#   required_version = ">= 1.12"
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 4.0"
#     }
#   }
# }

mock_provider "azurerm" {}

run "sets_correct_name" {
  variables {
    location = "westeurope"
    resource_group_name = "rg-mock"
    name = "vnet-mock"
    address_space = ["10.0.0.0/16"]

  }

  assert {
    condition     = azurerm_virtual_network.this.name == "vnet-mock"
    error_message = "vnet name should be 'vnet-mock'"
  }
}
run "sets_incorrect_name" {
  variables {
    location = "westeurope"
    resource_group_name = "rg-mock"
    name = "vnet-mock"
    address_space = ["10.0.0.0/16"]

  }

  assert {
    condition     = azurerm_virtual_network.this.name == "vnet-mock"
    error_message = "vnet name should be 'vnet-mock'"
  }
  assert {
    condition     = azurerm_virtual_network.this.tags == null
    error_message = "tags should default to null"
  }

  assert {
    condition     = local.name_rg == "vnet-mock-rg-mock"
    error_message = "local.name_rg should be 'vnet-mock-rg-mock'"
  }
}
