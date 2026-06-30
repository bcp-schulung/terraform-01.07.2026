output "resource_group_name" {
  description = "The name of the resource group"
  value       = data.azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = data.azurerm_resource_group.main.location
}

output "app_vnet_id" {
  description = "ID of the app VNet"
  value       = azurerm_virtual_network.app.id
}

output "client_vnet_id" {
  description = "ID of the client VNet"
  value       = azurerm_virtual_network.client.id
}

output "subnet_web_id" {
  description = "ID of the web subnet"
  value       = azurerm_subnet.web.id
}

output "subnet_backend_id" {
  description = "ID of the backend subnet"
  value       = azurerm_subnet.backend.id
}

output "subnet_db_id" {
  description = "ID of the db subnet"
  value       = azurerm_subnet.db.id
}

output "subnet_client_id" {
  description = "ID of the client subnet"
  value       = azurerm_subnet.client.id
}
