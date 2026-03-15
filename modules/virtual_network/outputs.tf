output "name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}
