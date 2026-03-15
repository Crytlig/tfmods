output "id" {
  description = "The resource ID of the virtual machine."
  value       = module.vm.resource_id
}

output "admin_username" {
  description = "The admin username of the virtual machine."
  value       = module.vm.admin_username
}

output "name" {
  description = "The name of the virtual machine."
  value       = module.vm.name
}

output "public_ip_address" {
  description = "The public IP address of the virtual machine, or null if public IP is disabled."
  value       = var.create_public_ip ? module.vm.public_ips.network_interface-ip_configuration_avs_facing.ip_address : null
}

output "network_security_group_id" {
  description = "The ID of the network security group."
  value       = azurerm_network_security_group.this.id
}

output "network_security_group_name" {
  description = "The name of the network security group."
  value       = azurerm_network_security_group.this.name
}

output "network_security_group_location" {
  description = "The location of the network security group."
  value       = azurerm_network_security_group.this.location
}

output "network_security_group_resource_group_name" {
  description = "The resource group name of the network security group."
  value       = azurerm_network_security_group.this.resource_group_name
}

output "network_security_group_security_rules" {
  description = "The security rules of the network security group."
  value       = azurerm_network_security_group.this.security_rule
}

output "private_ip_address" {
  description = "The private IP address of the virtual machine."
  value       = module.vm.network_interfaces.network_interface.private_ip_address
}
