output "id" {
  value = azurerm_private_endpoint.this.id
}

output "custom_dns_configs" {
  value = azurerm_private_endpoint.this.custom_dns_configs
}

output "subnet_id" {
  value = azurerm_private_endpoint.this.subnet_id
}

output "network_interface" {
  value = azurerm_private_endpoint.this.network_interface
}