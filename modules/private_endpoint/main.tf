resource "azurerm_private_endpoint" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = var.private_connection_name
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = var.private_connection_subresource_names
    is_manual_connection           = var.is_manual_connection
    request_message                = var.private_connection_request_message
  }

  private_dns_zone_group {
    name                 = var.private_dns_zone_group_name
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}