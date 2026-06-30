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

# ─── Imported: manually created VM + NIC + Public IP ─────────────────────────

import {
  to = azurerm_public_ip.test
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/publicIPAddresses/test-ip"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

import {
  to = azurerm_network_interface.test
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/networkInterfaces/test628_z2"
}

resource "azurerm_network_interface" "test" {
  name                = "test628_z2"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

import {
  to = azurerm_linux_virtual_machine.test
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Compute/virtualMachines/test"
}

resource "azurerm_linux_virtual_machine" "test" {
  name                = "test"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.test.id]

  os_disk {
    name                 = "test_OsDisk_1_3e33d8ac03f142f3871e493b67b05955"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # Azure does not expose SSH keys or passwords via the API — Terraform cannot
  # read them back on import. Add the matching admin_ssh_key block (or set
  # disable_password_authentication = false + admin_password) to avoid a
  # perpetual diff after import.
  disable_password_authentication = true
}
