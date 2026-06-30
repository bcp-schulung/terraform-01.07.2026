data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# ─── App VNet (web / backend / db tiers) ─────────────────────────────────────

resource "azurerm_virtual_network" "app" {
  name                = "${var.prefix}-app-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-backend"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "snet-db"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.3.0/24"]
}

# ─── NSGs ────────────────────────────────────────────────────────────────────

resource "azurerm_network_security_group" "web" {
  name                = "${var.prefix}-nsg-web"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
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
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "backend" {
  name                = "${var.prefix}-nsg-backend"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

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

  security_rule {
    name                       = "allow-rdp"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
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
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

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

# ─── Client VNet ──────────────────────────────────────────────────────────────

resource "azurerm_virtual_network" "client" {
  name                = "${var.prefix}-client-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_subnet" "client" {
  name                 = "snet-client"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.client.name
  address_prefixes     = ["10.1.1.0/24"]
}

# ─── VNet Peering ─────────────────────────────────────────────────────────────
# Peering must be created in both directions.

resource "azurerm_virtual_network_peering" "client_to_app" {
  name                      = "peer-client-to-app"
  resource_group_name       = data.azurerm_resource_group.main.name
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
  resource_group_name       = data.azurerm_resource_group.main.name
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

# ─── Backend Windows VM ───────────────────────────────────────────────────────

resource "azurerm_public_ip" "backend_vm" {
  name                = "${var.prefix}-backend-vm-pip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "backend_vm" {
  name                = "${var.prefix}-backend-vm-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.backend_vm.id
  }
}

resource "azurerm_windows_virtual_machine" "backend" {
  name                = "${var.prefix}-backend-vm"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.backend_vm.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}
