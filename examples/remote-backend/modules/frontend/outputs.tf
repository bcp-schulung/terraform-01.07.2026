output "app_service_url" {
  description = "Default hostname of the Linux Web App."
  value       = azurerm_linux_web_app.main.default_hostname
}

output "managed_identity_id" {
  description = "Principal ID of the App Service system-assigned managed identity."
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}
