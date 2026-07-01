# Module: frontend

Provisions the public-facing web tier inside `snet-web`. Deploys an Azure App Service (Linux) behind an Application Gateway with WAF in Prevention mode, enforces HTTPS-only with TLS 1.2+, and assigns a system-managed identity for Key Vault access.

## Usage

```hcl
module "frontend" {
  source              = "./modules/frontend"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  subnet_id           = module.networking.subnet_web_id
  backend_fqdn        = module.backend.vm_private_ip
  tags                = var.tags
}
```

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `resource_group_name` | `string` | yes | Name of the existing resource group |
| `location` | `string` | yes | Azure region for all resources |
| `prefix` | `string` | yes | Prefix applied to all resource names |
| `subnet_id` | `string` | yes | Resource ID of `snet-web` (from networking module) |
| `backend_fqdn` | `string` | yes | Private IP or FQDN of the backend tier |
| `tags` | `map(string)` | no | Tags applied to all resources (default: `{}`) |

## Outputs

| Name | Description |
|------|-------------|
| `app_service_url` | Default hostname of the Linux Web App |
| `managed_identity_id` | Principal ID of the App Service system-assigned managed identity |

## Resources

| Resource | Name pattern |
|----------|--------------|
| `azurerm_service_plan` | `<prefix>-asp` |
| `azurerm_linux_web_app` | `<prefix>-app` |
| `azurerm_application_gateway` | `<prefix>-agw` |

## Security notes

- HTTPS-only is enforced on the App Service; HTTP redirects to HTTPS.
- Minimum TLS version is set to 1.2.
- WAF policy is attached to the Application Gateway in **Prevention** mode.
- `nsg-web` rule for port 443 sources from the Application Gateway subnet only — not `*`.
- The App Service managed identity is used for Key Vault access; no credentials are stored in config.
