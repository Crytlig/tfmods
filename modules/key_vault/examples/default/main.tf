# Key vault module. Public access is denied by default
module "key_vault" {
  # source  = "github.com/crytlig/tfmods//modules/key_vault?ref=main"
  source              = "../../"
  name                = "kv-kv-example-${random_pet.example.id}"
  location            = "westeurope"
  resource_group_name = "rg-kv-example"

  network_acls = {
    virtual_network_subnet_ids = [azurerm_subnet.example.id]
    ip_rules                   = [local.ip]
  }

  role_assignments = {
    client_kv_secrets_officer = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azuread_client_config.example.object_id
      description                = "Example role assignment for the deployment client"
    }
  }

  # Wait for rbac propagation
  wait_for_rbac = {
    create  = 30
    destroy = 0
  }

  tags = {
    environment = "dev"
  }
}

############################################
################  Dependencies #############
############################################
data "azuread_client_config" "example" {}

data "http" "example" {
  url = "https://ipv4.icanhazip.com"
}

resource "random_pet" "example" {
  length = 2
}
locals {
  ip = "${chomp(data.http.example.response_body)}/32"
}


resource "azurerm_resource_group" "example" {
  name     = "rg-kv-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-kv-example"
  location            = "westeurope"
  resource_group_name = "rg-kv-example"
  address_space       = ["10.250.0.10/26"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "example" {
  name                 = "snet-kv-example"
  resource_group_name  = "rg-kv-example"
  virtual_network_name = "vnet-kv-example"
  address_prefixes     = ["10.250.0.12/28"]

  delegation {
    name = "kv-example"
    service_delegation {
      name = "Microsoft.KeyVault/vaults"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      ]
    }
  }
}