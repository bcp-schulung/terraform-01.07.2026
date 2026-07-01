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

# ─── NSGs ─────────────────────────────────────────────────────────────────────

resource "azurerm_network_security_group" "web" {
  name                = "${var.prefix}-nsg-web"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Source is scoped to the Application Gateway subnet — not *
  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.0.4.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.4.0/24"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "backend" {
  name                = "${var.prefix}-nsg-backend"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-from-web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  # RDP restricted to a specific CIDR — not *
  security_rule {
    name                       = "allow-rdp"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.trusted_rdp_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-internet-inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "db" {
  name                = "${var.prefix}-nsg-db"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-from-backend"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-internet-inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# ─── NSG associations ─────────────────────────────────────────────────────────

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.backend.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db.id
}

# Application Gateway v2 requires its own NSG with specific platform rules
resource "azurerm_network_security_group" "agw" {
  name                = "${var.prefix}-nsg-agw"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Mandatory: Azure platform uses this port range for AGW v2 health management
  security_rule {
    name                       = "allow-gateway-manager"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  # Required for health probes from the Azure internal load balancer
  security_rule {
    name                       = "allow-azure-load-balancer"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # Allow public HTTP/HTTPS traffic that the AGW will route
  security_rule {
    name                       = "allow-internet-http-https"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "agw" {
  subnet_id                 = azurerm_subnet.agw.id
  network_security_group_id = azurerm_network_security_group.agw.id
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
