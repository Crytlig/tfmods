output "name" {
  value = azurerm_linux_virtual_machine.this.name
}

output "id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "nic_id" {
  value = azurerm_network_interface.this.id
}

output "public_ip_address" {
  value = azurerm_public_ip.this[0].ip_address
}

output "private_ip_address" {
  value = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address_id" {
  value = azurerm_public_ip.this[0].id
}
