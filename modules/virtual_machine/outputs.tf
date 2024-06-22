output "name" {
  value = azurerm_linux_virtual_machine.this.name
}


output "id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "nic_id" {
  value = azurerm_network_interface.this.id
}