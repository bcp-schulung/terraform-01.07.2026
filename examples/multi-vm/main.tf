data "azurerm_resource_group" "main" {
    name = var.resource_group_name
}

resource "tls_private_key" "main" {
  algorithm = "ED25519"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-${var.vm_name}-subnet"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "main" {
  for_each            = var.vms
  name                = "${var.prefix}-${each.key}-pip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "main" {
  for_each            = var.vms
  name                = "${var.prefix}-${each.key}-nsg"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  dynamic "security_rule" {
    for_each = { for idx, port in each.value.open_ports : port => idx }
    content {
      name = "open-port-${security_rule.key}"
      priority = 100
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range     = security_rule.key
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_interface" "main" {
  for_each            = var.vms
  name                = "${var.prefix}-${each.key}-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  for_each = var.vms
  network_interface_id      = azurerm_network_interface.main[each.key].id
  network_security_group_id = azurerm_network_security_group.main[each.key].id
}

resource "azurerm_linux_virtual_machine" "main" {
  for_each = var.vms
  name                = "${var.prefix}-${each.key}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  size                = each.value.size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.main[each.key].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.main.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}