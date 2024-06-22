module "resource_group" {
  source = "../"

  name = "rg-workload"
  location = "westeurope"

  tags = {
    environment = "dev"
  }
}
