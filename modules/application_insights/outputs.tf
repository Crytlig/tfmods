output "id" {
  description = "ID of the Application Insights instance."
  value       = azurerm_application_insights.this.id
}

output "instrumentation_key" {
  description = "The instrumentation key of the Application Insights instance."
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "The connection string of the Application Insights instance."
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}

output "app_id" {
  description = "The application ID of the Application Insights instance."
  value       = azurerm_application_insights.this.app_id
}
