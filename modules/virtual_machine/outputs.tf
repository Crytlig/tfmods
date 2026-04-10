output "name" {
  description = "The name of the virtual machine."
  value       = azurerm_linux_virtual_machine.this.name
}

output "id" {
  description = "The resource ID of the virtual machine."
  value       = azurerm_linux_virtual_machine.this.id
}

output "nic_id" {
  description = "The ID of the network interface."
  value       = azurerm_network_interface.this.id
}

output "public_ip_address" {
  description = "The public IP address of the virtual machine, or null if public IP is disabled."
  value       = var.enable_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "private_ip_address" {
  description = "The private IP address of the virtual machine."
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address_id" {
  description = "The ID of the public IP address resource, or null if public IP is disabled."
  value       = var.enable_public_ip ? azurerm_public_ip.this[0].id : null
}
