resource "azurerm_virtual_network" "this" {
  name                = var.name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags

  # Deployed as a separate resource
  lifecycle {
    ignore_changes = [subnet]
  }
}

locals {
  name_rg = "${azurerm_virtual_network.this.name}-${azurerm_virtual_network.this.resource_group_name}"
}
