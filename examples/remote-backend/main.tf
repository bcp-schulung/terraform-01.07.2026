data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# ─── Networking ───────────────────────────────────────────────────────────────

module "networking" {
  source              = "./modules/networking"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  trusted_rdp_cidr    = var.trusted_rdp_cidr
  tags                = var.tags
}

# ─── Database & shared Key Vault ──────────────────────────────────────────────

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

# ─── Backend ──────────────────────────────────────────────────────────────────

module "backend" {
  source              = "./modules/backend"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  subnet_id           = module.networking.subnet_backend_id
  admin_username      = var.admin_username
  key_vault_id        = module.database.key_vault_id
  tags                = var.tags
}

# ─── Frontend ─────────────────────────────────────────────────────────────────

module "frontend" {
  source              = "./modules/frontend"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  agw_subnet_id       = module.networking.subnet_agw_id
  tags                = var.tags
}
