output "resource_group_name" {
  description = "The name of the resource group."
  value       = data.azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The location of the resource group."
  value       = data.azurerm_resource_group.main.location
}

output "app_vnet_id" {
  description = "Resource ID of the App VNet."
  value       = module.networking.app_vnet_id
}

output "subnet_web_id" {
  description = "Resource ID of snet-web."
  value       = module.networking.subnet_web_id
}

output "subnet_backend_id" {
  description = "Resource ID of snet-backend."
  value       = module.networking.subnet_backend_id
}

output "subnet_db_id" {
  description = "Resource ID of snet-db."
  value       = module.networking.subnet_db_id
}

output "subnet_client_id" {
  description = "Resource ID of snet-client."
  value       = module.networking.subnet_client_id
}

output "backend_vm_public_ip" {
  description = "Public IP address of the backend Windows VM — use for RDP."
  value       = module.backend.vm_public_ip
}

output "backend_vm_private_ip" {
  description = "Private IP address of the backend Windows VM."
  value       = module.backend.vm_private_ip
}

output "app_service_url" {
  description = "Default hostname of the frontend App Service."
  value       = module.frontend.app_service_url
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server."
  value       = module.database.sql_server_fqdn
}

output "sql_database_name" {
  description = "Name of the SQL database."
  value       = module.database.sql_database_name
}
