resource "azurerm_subnet" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes
  service_endpoints    = var.service_endpoints

  dynamic "delegation" {
    for_each = var.service_delegation == null ? [] : [1]
    content {
      name = "delegation"
      service_delegation {
        name = var.service_delegation
      }
    }
  }
}

resource "azurerm_subnet_route_table_association" "this" {
  count          = var.route_table_id == null ? 0 : 1
  subnet_id      = azurerm_subnet.this.id
  route_table_id = var.route_table_id
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = var.network_security_group_id == null ? 0 : 1
  network_security_group_id = var.network_security_group_id
  subnet_id                 = azurerm_subnet.this.id
}
