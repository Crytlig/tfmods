output "id" {
  description = "The ID of the Linux web app."
  value       = azurerm_linux_web_app.this.id
}

output "default_hostname" {
  description = "The default hostname of the Linux web app."
  value       = azurerm_linux_web_app.this.default_hostname
}

output "identity" {
  description = "The identity block of the Linux web app."
  value       = azurerm_linux_web_app.this.identity
}
