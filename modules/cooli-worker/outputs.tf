output "id" {
  value = module.vm.resource_id
}

output "admin_username" {
  value = module.vm.admin_username
}

output "name" {
  value = module.vm.name
}

output "public_ip_address" {
  value = module.vm.public_ips.network_interface-ip_configuration_avs_facing.ip_address
}

output "network_security_group_id" {
  value = azurerm_network_security_group.this.id
}

output "network_security_group_name" {
  value = azurerm_network_security_group.this.name
}

output "network_security_group_location" {
  value = azurerm_network_security_group.this.location
}

output "network_security_group_resource_group_name" {
  value = azurerm_network_security_group.this.resource_group_name
}

output "network_security_group_security_rules" {
  value = azurerm_network_security_group.this.security_rule
}
