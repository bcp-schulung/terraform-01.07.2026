output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server."
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Name of the SQL database."
  value       = azurerm_mssql_database.main.name
}

output "key_vault_id" {
  description = "Resource ID of the shared Key Vault (passed to the backend module)."
  value       = azurerm_key_vault.main.id
}
