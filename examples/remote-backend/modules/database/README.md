# Module: database

Provisions the database tier and shared platform services. Deploys an Azure SQL Server (v12, Azure AD admin, no public access) with a Basic database, a private endpoint in `snet-db`, a private DNS zone linked to the App VNet, an Azure Key Vault for shared secrets, and diagnostic settings that stream SQL audit logs to a Log Analytics Workspace.

## Usage

```hcl
module "database" {
  source              = "./modules/database"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  subnet_db_id        = module.networking.subnet_db_id
  app_vnet_id         = module.networking.app_vnet_id
  sql_admin_username  = var.sql_admin_username
  aad_admin_object_id = var.aad_admin_object_id
  tags                = var.tags
}
```

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `resource_group_name` | `string` | yes | Name of the existing resource group |
| `location` | `string` | yes | Azure region for all resources |
| `prefix` | `string` | yes | Prefix applied to all resource names |
| `subnet_db_id` | `string` | yes | Resource ID of `snet-db` (from networking module) |
| `app_vnet_id` | `string` | yes | Resource ID of the App VNet (for DNS zone link) |
| `sql_admin_username` | `string` | yes | SQL Server administrator login name |
| `aad_admin_object_id` | `string` | yes | Azure AD object ID of the SQL Azure AD administrator |
| `tags` | `map(string)` | no | Tags applied to all resources (default: `{}`) |

## Outputs

| Name | Description |
|------|-------------|
| `sql_server_fqdn` | Fully qualified domain name of the SQL Server |
| `sql_database_name` | Name of the SQL database |
| `key_vault_id` | Resource ID of the shared Key Vault (passed to the backend module) |

## Resources

| Resource | Name pattern |
|----------|--------------|
| `azurerm_key_vault` | `<prefix>-kv` |
| `azurerm_mssql_server` | `<prefix>-sql` |
| `azurerm_mssql_database` | `<prefix>-sqldb` (Basic SKU, 2 GB max) |
| `azurerm_private_endpoint` | `<prefix>-pe-sql` (in `snet-db`) |
| `azurerm_private_dns_zone` | `privatelink.database.windows.net` |
| `azurerm_private_dns_zone_virtual_network_link` | `<prefix>-dns-link` |
| `azurerm_log_analytics_workspace` | `<prefix>-law` |
| `azurerm_monitor_diagnostic_setting` | — (SQL audit logs → Log Analytics) |

## Security notes

- Public network access is disabled on the SQL Server; connectivity is via private endpoint only.
- SQL admin password is stored as a secret in the Key Vault; no plaintext credential appears in any `.tf` or `.tfvars` file.
- Azure AD admin is configured on the SQL Server for Entra-based authentication.
- The shared Key Vault ID is exported so the backend module can reference it for its own secrets.
