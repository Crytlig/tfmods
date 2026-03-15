output "id" {
  description = "The ID of the private endpoint."
  value       = azurerm_private_endpoint.this.id
}

output "custom_dns_configs" {
  description = "The custom DNS configurations of the private endpoint."
  value       = azurerm_private_endpoint.this.custom_dns_configs
}

output "subnet_id" {
  description = "The ID of the subnet associated with the private endpoint."
  value       = azurerm_private_endpoint.this.subnet_id
}

output "network_interface" {
  description = "The network interface associated with the private endpoint."
  value       = azurerm_private_endpoint.this.network_interface
}
