# ─── App VNet ─────────────────────────────────────────────────────────────────

resource "azurerm_virtual_network" "app" {
  name                = "${var.prefix}-app-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-backend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "snet-db"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Dedicated subnet required by Application Gateway v2
resource "azurerm_subnet" "agw" {
  name                 = "snet-agw"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.4.0/24"]
}

# ─── Client VNet ──────────────────────────────────────────────────────────────

resource "azurerm_virtual_network" "client" {
  name                = "${var.prefix}-client-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "client" {
  name                 = "snet-client"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.client.name
  address_prefixes     = ["10.1.1.0/24"]
}

# ─── VNet Peering ─────────────────────────────────────────────────────────────

resource "azurerm_virtual_network_peering" "client_to_app" {
  name                      = "peer-client-to-app"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.client.name
  remote_virtual_network_id = azurerm_virtual_network.app.id
  allow_forwarded_traffic   = true

  depends_on = [
    azurerm_subnet_network_security_group_association.web,
    azurerm_subnet_network_security_group_association.backend,
    azurerm_subnet_network_security_group_association.db,
    azurerm_subnet.client,
  ]
}

resource "azurerm_virtual_network_peering" "app_to_client" {
  name                      = "peer-app-to-client"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.app.name
  remote_virtual_network_id = azurerm_virtual_network.client.id
  allow_forwarded_traffic   = true

  depends_on = [
    azurerm_subnet_network_security_group_association.web,
    azurerm_subnet_network_security_group_association.backend,
    azurerm_subnet_network_security_group_association.db,
    azurerm_subnet.client,
  ]
}
