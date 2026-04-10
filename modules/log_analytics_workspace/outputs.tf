output "id" {
  description = "ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_id" {
  description = "The unique workspace GUID."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "primary_shared_key" {
  description = "The primary shared key of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}
