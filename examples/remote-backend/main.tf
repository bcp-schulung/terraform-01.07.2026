data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# ─── Networking ───────────────────────────────────────────────────────────────

module "networking" {
  source              = "./modules/networking"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  tags                = var.tags
  trusted_rdp_cidr    = var.trusted_rdp_cidr
}




# ─── Frontend ─────────────────────────────────────────────────────────────────

module "frontend" {
  source              = "./modules/frontend"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  subnet_id           = module.networking.subnet_web_id
  agw_subnet_id       = module.networking.subnet_agw_id
  backend_fqdn        = module.backend.vm_private_ip
  tags                = var.tags
}
