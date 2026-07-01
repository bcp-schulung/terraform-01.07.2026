# Module: networking

Provisions the full network topology for the three-tier application stack: App VNet with web/backend/db subnets, a Client VNet, NSGs for each tier, NSG associations, and bidirectional VNet peering.

## Usage

```hcl
module "networking" {
  source              = "./modules/networking"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  tags                = var.tags
}
```

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `resource_group_name` | `string` | yes | Name of the existing resource group |
| `location` | `string` | yes | Azure region for all resources |
| `prefix` | `string` | yes | Prefix applied to all resource names |
| `tags` | `map(string)` | no | Tags applied to all resources (default: `{}`) |

## Outputs

| Name | Description |
|------|-------------|
| `subnet_web_id` | Resource ID of `snet-web` (10.0.1.0/24) |
| `subnet_backend_id` | Resource ID of `snet-backend` (10.0.2.0/24) |
| `subnet_db_id` | Resource ID of `snet-db` (10.0.3.0/24) |
| `subnet_client_id` | Resource ID of `snet-client` (10.1.1.0/24) |
| `app_vnet_id` | Resource ID of the App VNet |

## Resources

| Resource | Name pattern |
|----------|--------------|
| `azurerm_virtual_network` (App) | `<prefix>-app-vnet` |
| `azurerm_virtual_network` (Client) | `<prefix>-client-vnet` |
| `azurerm_subnet` (web / backend / db / client) | `snet-web`, `snet-backend`, `snet-db`, `snet-client` |
| `azurerm_network_security_group` (×3) | `<prefix>-nsg-web/backend/db` |
| `azurerm_subnet_network_security_group_association` (×3) | — |
| `azurerm_virtual_network_peering` (×2) | `peer-client-to-app`, `peer-app-to-client` |

## NSG rules summary

| NSG | Rule | Port | Source |
|-----|------|------|--------|
| `nsg-web` | allow-http | 80 | App Gateway subnet |
| `nsg-web` | allow-https | 443 | App Gateway subnet |
| `nsg-backend` | allow-from-web | 8080 | 10.0.1.0/24 |
| `nsg-backend` | allow-rdp | 3389 | `trusted_rdp_cidr` |
| `nsg-backend` | deny-internet-inbound | * | Internet |
| `nsg-db` | allow-from-backend | 1433 | 10.0.2.0/24 |
| `nsg-db` | deny-internet-inbound | * | Internet |
