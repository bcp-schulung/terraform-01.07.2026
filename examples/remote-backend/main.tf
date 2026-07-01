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
