output "id" {
  description = "ID of the App Service Plan."
  value       = azurerm_service_plan.this.id
}

output "name" {
  description = "Name of the App Service Plan."
  value       = azurerm_service_plan.this.name
}

output "os_type" {
  description = "The OS type of the App Service Plan."
  value       = azurerm_service_plan.this.os_type
}

output "kind" {
  description = "The kind value of the App Service Plan."
  value       = azurerm_service_plan.this.kind
}
