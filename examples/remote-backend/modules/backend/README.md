# Module: backend

Hardens and extends the Windows VM in `snet-backend`. Manages the VM's public IP, NIC, and OS disk; retrieves the admin password from Azure Key Vault; enables a system-assigned managed identity; configures auto-shutdown at 19:00 UTC; and protects the VM with a daily Azure Backup policy.

## Usage

```hcl
module "backend" {
  source              = "./modules/backend"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  subnet_id           = module.networking.subnet_backend_id
  admin_username      = var.admin_username
  key_vault_id        = module.database.key_vault_id
  trusted_rdp_cidr    = var.trusted_rdp_cidr
  tags                = var.tags
}
```

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `resource_group_name` | `string` | yes | Name of the existing resource group |
| `location` | `string` | yes | Azure region for all resources |
| `prefix` | `string` | yes | Prefix applied to all resource names |
| `subnet_id` | `string` | yes | Resource ID of `snet-backend` (from networking module) |
| `admin_username` | `string` | yes | Local administrator username for the Windows VM |
| `key_vault_id` | `string` | yes | Resource ID of the Key Vault that holds the VM admin password secret |
| `trusted_rdp_cidr` | `string` | yes | CIDR block allowed to RDP to the VM (e.g. `203.0.113.10/32`) |
| `tags` | `map(string)` | no | Tags applied to all resources (default: `{}`) |

## Outputs

| Name | Description |
|------|-------------|
| `vm_id` | Resource ID of the Windows VM |
| `vm_private_ip` | Private IP address of the VM NIC |
| `vm_public_ip` | Public IP address assigned to the VM |
| `vm_identity_id` | Principal ID of the VM system-assigned managed identity |

## Resources

| Resource | Name pattern |
|----------|--------------|
| `azurerm_public_ip` | `<prefix>-pip-backend-vm` |
| `azurerm_network_interface` | `<prefix>-nic-backend-vm` |
| `azurerm_windows_virtual_machine` | `<prefix>-vm-backend` |
| `azurerm_key_vault_access_policy` | — (grants VM identity `get`/`list` on secrets) |
| `azurerm_dev_test_global_vm_shutdown_schedule` | — (19:00 UTC daily) |
| `azurerm_recovery_services_vault` | `<prefix>-rsv` |
| `azurerm_backup_policy_vm` | `<prefix>-backup-policy` (daily, 7-day retention) |
| `azurerm_backup_protected_vm` | — |

## Security notes

- Admin password is stored as a secret in Key Vault (`vm-admin-password`); no plaintext credential appears in any `.tf` or `.tfvars` file.
- RDP (`allow-rdp`) NSG rule is scoped to `trusted_rdp_cidr` — not `*`.
- VM has a system-assigned managed identity; Key Vault access policy grants only `get` and `list` on secrets.
