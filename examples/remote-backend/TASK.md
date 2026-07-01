# Team Task: Full-Stack Azure Infrastructure with Terraform Modules

## Overview

Working from the existing baseline configuration in this directory, your team of three will extend and refactor it into a production-quality, fully modular Terraform project that provisions a three-tier application stack on Azure — frontend, backend, and database — complete with automated tests and CI/CD pipeline support.

The existing baseline gives you:
- A resource group data source
- An App VNet with `snet-web`, `snet-backend`, and `snet-db` subnets
- NSGs for each tier with basic inbound rules
- A Client VNet with bidirectional peering to the App VNet
- A Windows VM in the backend subnet with a public IP and RDP access
- Remote state stored in Azure Blob Storage

Your job is to build on top of this, not replace it.

---

## Team Roles

| Person | Role | Primary Modules |
|--------|------|-----------------|
| **Person A** | Frontend Engineer | `modules/frontend` |
| **Person B** | Backend Engineer | `modules/backend` |
| **Person C** | Database & Platform Engineer | `modules/database`, `modules/networking` |

Each person owns their module end-to-end: resources, variables, outputs, and tests.

---

## Target Project Structure

```
examples/remote-backend/
├── main.tf                  # Root: calls all modules
├── variables.tf             # Root-level variables
├── outputs.tf               # Root-level outputs
├── terraform.tfvars         # Environment values (gitignored)
├── provider.tf              # Provider + remote backend config
├── versions.tf              # required_providers pinned versions
│
├── modules/
│   ├── networking/          # Person C
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── frontend/            # Person A
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── backend/             # Person B
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── database/            # Person C
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
└── tests/
    ├── frontend_test.go     # Person A
    ├── backend_test.go      # Person B
    └── database_test.go     # Person C
```

---

## Person A — Frontend Module

### Goal
Provision the public-facing web tier in `snet-web` using Azure App Service (or an Azure Load Balancer + VM scale set if preferred) that serves traffic over HTTPS.

### Required Resources

- **Azure App Service Plan** — `Standard_S1` or higher, Linux
- **Azure App Service (Web App)** — with HTTPS-only enforced, minimum TLS 1.2
- **Azure Application Gateway** or **Azure Front Door** — for SSL termination and WAF (Web Application Firewall) in Prevention mode
- **Managed Identity** assigned to the App Service for Key Vault access
- **NSG update** — extend the existing `nsg-web` to allow port 443 from the Application Gateway subnet only; remove the permissive `*` source

### Module Interface

**Inputs:**
```hcl
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "prefix"              { type = string }
variable "subnet_id"           { type = string }  # snet-web ID from networking module
variable "backend_fqdn"        { type = string }  # passed from backend module output
variable "tags"                { type = map(string); default = {} }
```

**Outputs:**
```hcl
output "app_service_url"       { value = azurerm_linux_web_app.main.default_hostname }
output "managed_identity_id"   { value = azurerm_linux_web_app.main.identity[0].principal_id }
```

### Acceptance Criteria

- [ ] `terraform plan` produces no errors
- [ ] App Service returns HTTP 200 on its default URL after `terraform apply`
- [ ] HTTPS is enforced — HTTP redirects to HTTPS
- [ ] WAF is enabled and set to Prevention mode
- [ ] Managed Identity is assigned and output correctly
- [ ] NSG source for port 443 is scoped to the Application Gateway subnet, not `*`

---

## Person B — Backend Module

### Goal
Harden and extend the existing Windows VM in `snet-backend` and surround it with the supporting services a real backend tier needs.

### Required Resources

- **Refactor the existing VM** into the `modules/backend` module (move the `azurerm_public_ip`, `azurerm_network_interface`, and `azurerm_windows_virtual_machine` resources out of `main.tf` and into the module)
- **Azure Key Vault** — store the VM admin password as a secret; remove the plaintext password from `terraform.tfvars`. Reference the secret via a `data` source during provisioning
- **Azure Key Vault Access Policy** — grant the VM's system-assigned managed identity `get`/`list` on secrets
- **Auto-shutdown schedule** (`azurerm_dev_test_global_vm_shutdown_schedule`) — shut down at 19:00 UTC daily to save cost
- **Azure Backup** — `azurerm_backup_protected_vm` using a Recovery Services Vault with a daily policy (retain 7 days)
- **NSG update** — restrict the RDP `allow-rdp` rule so `source_address_prefix` is a specific trusted IP or CIDR instead of `*`

### Module Interface

**Inputs:**
```hcl
variable "resource_group_name"  { type = string }
variable "location"             { type = string }
variable "prefix"               { type = string }
variable "subnet_id"            { type = string }  # snet-backend ID
variable "admin_username"       { type = string }
variable "key_vault_id"         { type = string }  # from database/platform module
variable "trusted_rdp_cidr"     { type = string }  # e.g. "203.0.113.10/32"
variable "tags"                 { type = map(string); default = {} }
```

**Outputs:**
```hcl
output "vm_id"             { value = azurerm_windows_virtual_machine.backend.id }
output "vm_private_ip"     { value = azurerm_network_interface.backend_vm.private_ip_address }
output "vm_public_ip"      { value = azurerm_public_ip.backend_vm.ip_address }
output "vm_identity_id"    { value = azurerm_windows_virtual_machine.backend.identity[0].principal_id }
```

### Acceptance Criteria

- [ ] `terraform plan` produces no errors
- [ ] Admin password is stored in Key Vault; no plaintext secret in any `.tf` or `.tfvars` file
- [ ] VM has a system-assigned managed identity
- [ ] Auto-shutdown is configured for 19:00 UTC
- [ ] Daily backup policy exists and VM is protected
- [ ] RDP rule source is a specific CIDR, not `*`

---

## Person C — Networking & Database Modules

### Goal
Refactor the existing networking resources into a reusable module, and provision a fully managed Azure SQL database for the db tier.

### Networking Module

Move all VNet, subnet, NSG, NSG-association, and peering resources out of the root `main.tf` into `modules/networking`. The root `main.tf` should call this module and pass subnet IDs to the other modules.

**Inputs:**
```hcl
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "prefix"              { type = string }
variable "tags"                { type = map(string); default = {} }
```

**Outputs:**
```hcl
output "subnet_web_id"      { value = azurerm_subnet.web.id }
output "subnet_backend_id"  { value = azurerm_subnet.backend.id }
output "subnet_db_id"       { value = azurerm_subnet.db.id }
output "subnet_client_id"   { value = azurerm_subnet.client.id }
output "app_vnet_id"        { value = azurerm_virtual_network.app.id }
```

### Database Module

**Required Resources:**

- **Azure SQL Server** (`azurerm_mssql_server`) — version 12.0, Azure AD admin set, public network access disabled
- **Azure SQL Database** (`azurerm_mssql_database`) — `Basic` SKU (cheapest for a lab), max size 2 GB
- **Private Endpoint** (`azurerm_private_endpoint`) — place in `snet-db`, connected to the SQL server `sqlServer` sub-resource
- **Private DNS Zone** (`azurerm_private_dns_zone`) — `privatelink.database.windows.net`, linked to the App VNet
- **Azure Key Vault** — store the SQL admin password as a secret; share this vault with Person B's module via output
- **Diagnostic settings** — send SQL audit logs to a Log Analytics Workspace

**Inputs:**
```hcl
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "prefix"              { type = string }
variable "subnet_db_id"        { type = string }
variable "app_vnet_id"         { type = string }
variable "sql_admin_username"  { type = string }
variable "aad_admin_object_id" { type = string }  # your own Azure AD object ID
variable "tags"                { type = map(string); default = {} }
```

**Outputs:**
```hcl
output "sql_server_fqdn"   { value = azurerm_mssql_server.main.fully_qualified_domain_name }
output "sql_database_name" { value = azurerm_mssql_database.main.name }
output "key_vault_id"      { value = azurerm_key_vault.main.id }
```

### Acceptance Criteria

- [ ] All existing resources are inside `modules/networking`; root `main.tf` only calls modules
- [ ] SQL server has no public network access
- [ ] SQL is reachable from `snet-backend` via the private endpoint only
- [ ] SQL admin password is in Key Vault; no plaintext in source files
- [ ] Azure AD admin is configured on the SQL server
- [ ] Private DNS zone resolves correctly within the App VNet

---

## Tests (All Team Members)

Use [Terratest](https://terratest.gruntwork.io/) (Go) to write integration tests for your module. Each test should:

1. Run `terraform init` and `terraform apply` against a real Azure subscription (use a dedicated test resource group)
2. Assert the key outputs are non-empty / match expected values
3. Run `terraform destroy` in a deferred cleanup step

### Minimum test coverage per module

**`tests/frontend_test.go`** (Person A)
- Assert `app_service_url` is non-empty
- Assert the URL returns HTTP 200 or 301/302 (reachable)

**`tests/backend_test.go`** (Person B)
- Assert `vm_public_ip` is a valid IPv4 address
- Assert Key Vault secret `vm-admin-password` exists and is non-empty

**`tests/database_test.go`** (Person C)
- Assert `sql_server_fqdn` ends with `.database.windows.net`
- Assert private endpoint NIC is in `snet-db`

### Running tests

```bash
cd examples/remote-backend
go mod init terraform-tests
go mod tidy
go test ./tests/ -v -timeout 30m
```

---

## Shared Conventions

All team members must follow these conventions to ensure the modules compose cleanly.

| Convention | Rule |
|------------|------|
| **Naming** | All resource names use `${var.prefix}-<resource>` |
| **Tags** | Every resource accepts and applies a `var.tags` map |
| **Secrets** | No plaintext secrets in any `.tf` or `.tfvars` file — use Key Vault |
| **Outputs** | Every module must output at minimum its primary resource IDs |
| **README** | Each module directory must have a `README.md` with inputs/outputs table |
| **Formatting** | All files pass `terraform fmt -check` before committing |
| **Validation** | All files pass `terraform validate` before committing |

---

## Integration: Root `main.tf`

Once all three modules are complete, the root `main.tf` should look roughly like this:

```hcl
module "networking" {
  source              = "./modules/networking"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  tags                = var.tags
}

module "database" {
  source              = "./modules/database"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  prefix              = var.prefix
  subnet_db_id        = module.networking.subnet_db_id
  app_vnet_id         = module.networking.app_vnet_id
  sql_admin_username  = var.sql_admin_username
  aad_admin_object_id = var.aad_admin_object_id
  tags                = var.tags
}

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

---

## Definition of Done

The task is complete when:

- [ ] All four modules exist with their required resources, variables, and outputs
- [ ] Root `main.tf` calls all modules — no raw resources at the root level (except the `data` source)
- [ ] `terraform fmt -check` passes on all files
- [ ] `terraform validate` passes on all files
- [ ] `terraform plan` runs without errors against the `rg-tf-lab` resource group
- [ ] All three test files exist and pass with `go test ./tests/ -v -timeout 30m`
- [ ] Each module has a `README.md` with an inputs/outputs table
- [ ] No secrets appear in any committed file
