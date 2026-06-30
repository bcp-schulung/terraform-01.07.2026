output "resource_group_name" {
  description = "The name of the resource group"
  value       = data.azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = data.azurerm_resource_group.main.location
}

output "resource_group_id" {
  description = "The resource group ID"
  value       = data.azurerm_resource_group.main.id
}
