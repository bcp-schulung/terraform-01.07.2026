output "subnet_web_id" {
  description = "Resource ID of snet-web."
  value       = azurerm_subnet.web.id
}

output "subnet_backend_id" {
  description = "Resource ID of snet-backend."
  value       = azurerm_subnet.backend.id
}

output "subnet_db_id" {
  description = "Resource ID of snet-db."
  value       = azurerm_subnet.db.id
}

output "subnet_client_id" {
  description = "Resource ID of snet-client."
  value       = azurerm_subnet.client.id
}

output "app_vnet_id" {

  value       = azurerm_virtual_network.app.id
}
