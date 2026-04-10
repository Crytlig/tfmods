module "user_assigned_identity" {
  # source = "github.com/crytlig/tfmods//modules/user_assigned_identity?ref=main"
  source = "../../"

  name                = "id-example"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name

  federated_identity_credentials = {
    github_actions = {
      issuer  = "https://token.actions.githubusercontent.com"
      subject = "repo:example-org/example-repo:ref:refs/heads/main"
    }
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "rg-id-example"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
