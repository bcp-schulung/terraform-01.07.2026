# These resources already exist in Azure from a previous apply.
# Import blocks pull them into the current module state so apply can manage them.

# ─── Networking ───────────────────────────────────────────────────────────────

import {
  to = module.networking.azurerm_virtual_network.app
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-app-vnet"
}

import {
  to = module.networking.azurerm_virtual_network.client
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-client-vnet"
}

import {
  to = module.networking.azurerm_network_security_group.web
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/networkSecurityGroups/lab-nsg-web"
}

import {
  to = module.networking.azurerm_network_security_group.backend
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/networkSecurityGroups/lab-nsg-backend"
}

import {
  to = module.networking.azurerm_network_security_group.db
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/networkSecurityGroups/lab-nsg-db"
}

import {
  to = module.networking.azurerm_subnet.web
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-app-vnet/subnets/snet-web"
}

import {
  to = module.networking.azurerm_subnet.backend
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-app-vnet/subnets/snet-backend"
}

import {
  to = module.networking.azurerm_subnet.db
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-app-vnet/subnets/snet-db"
}

import {
  to = module.networking.azurerm_subnet.client
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-client-vnet/subnets/snet-client"
}

import {
  to = module.networking.azurerm_subnet_network_security_group_association.web
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-app-vnet/subnets/snet-web"
}

import {
  to = module.networking.azurerm_subnet_network_security_group_association.backend
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-app-vnet/subnets/snet-backend"
}

import {
  to = module.networking.azurerm_subnet_network_security_group_association.db
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-app-vnet/subnets/snet-db"
}

import {
  to = module.networking.azurerm_virtual_network_peering.client_to_app
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-client-vnet/virtualNetworkPeerings/peer-client-to-app"
}

import {
  to = module.networking.azurerm_virtual_network_peering.app_to_client
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-app-vnet/virtualNetworkPeerings/peer-app-to-client"
}

# ─── Backend ──────────────────────────────────────────────────────────────────

import {
  to = module.backend.azurerm_public_ip.backend_vm
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/publicIPAddresses/lab-pip-backend-vm"
}

import {
  to = module.backend.azurerm_recovery_services_vault.main
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.RecoveryServices/vaults/lab-rsv"
}

# ─── Database ─────────────────────────────────────────────────────────────────

import {
  to = module.database.azurerm_private_dns_zone.sql
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
}

import {
  to = module.database.azurerm_log_analytics_workspace.main
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.OperationalInsights/workspaces/lab-law"
}

# ─── Frontend ─────────────────────────────────────────────────────────────────

import {
  to = module.frontend.azurerm_public_ip.agw
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/publicIPAddresses/lab-pip-agw"
}

import {
  to = module.frontend.azurerm_web_application_firewall_policy.main
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/lab-waf-policy"
}

# ─── Additional resources created by partial applies ──────────────────────────

import {
  to = module.backend.azurerm_network_interface.backend_vm
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/networkInterfaces/lab-nic-backend-vm"
}

import {
  to = module.backend.azurerm_backup_policy_vm.daily
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.RecoveryServices/vaults/lab-rsv/backupPolicies/lab-backup-policy"
}

import {
  to = module.database.azurerm_private_dns_zone_virtual_network_link.sql
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net/virtualNetworkLinks/lab-dns-link"
}

import {
  to = module.networking.azurerm_subnet.agw
  id = "/subscriptions/cbc7eedf-6bc9-4ba6-aba0-ec01f95cb078/resourceGroups/rg-tf-lab/providers/Microsoft.Network/virtualNetworks/lab-app-vnet/subnets/snet-agw"
}
