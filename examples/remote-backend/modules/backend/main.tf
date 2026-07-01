data "azurerm_client_config" "current" {}

# ─── VM admin password — generated and stored in the shared Key Vault ─────────

resource "random_password" "vm_admin" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "vm-admin-password"
  value        = random_password.vm_admin.result
  key_vault_id = var.key_vault_id
}

# ─── Network resources ────────────────────────────────────────────────────────

resource "azurerm_public_ip" "backend_vm" {
  name                = "${var.prefix}-pip-backend-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "backend_vm" {
  name                = "${var.prefix}-nic-backend-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.backend_vm.id
  }
}

# ─── Windows VM ───────────────────────────────────────────────────────────────

resource "azurerm_windows_virtual_machine" "backend" {
  name                = "${var.prefix}-vm-backend"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  admin_password      = random_password.vm_admin.result
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.backend_vm.id]

  identity {
    type = "SystemAssigned"
  }

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

  depends_on = [azurerm_key_vault_secret.vm_admin_password]
}

# Grant the VM's managed identity read access to Key Vault secrets
resource "azurerm_key_vault_access_policy" "vm_identity" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_virtual_machine.backend.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

# ─── Auto-shutdown at 19:00 UTC ───────────────────────────────────────────────

resource "azurerm_dev_test_global_vm_shutdown_schedule" "backend" {
  virtual_machine_id    = azurerm_windows_virtual_machine.backend.id
  location              = var.location
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }
}

# ─── Backup (daily policy, 7-day retention) ───────────────────────────────────

resource "azurerm_recovery_services_vault" "main" {
  name                = "${var.prefix}-rsv"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "daily" {
  name                = "${var.prefix}-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "backend" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  source_vm_id        = azurerm_windows_virtual_machine.backend.id
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}
