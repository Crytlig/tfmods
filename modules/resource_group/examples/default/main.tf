module "resource_group" {
  source = "github.com/crytlig/tfmods//modules/resource_group?ref=main"
  # source = "../../"

  name     = "rg-workload"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
