output "vm_id" {
  description = "Resource ID of the Windows VM."
  value       = azurerm_windows_virtual_machine.backend.id
}

output "vm_private_ip" {
  description = "Private IP address of the VM NIC."
  value       = azurerm_network_interface.backend_vm.private_ip_address
}

output "vm_public_ip" {
  description = "Public IP address assigned to the VM."
  value       = azurerm_public_ip.backend_vm.ip_address
}

output "vm_identity_id" {
  description = "Principal ID of the VM system-assigned managed identity."
  value       = azurerm_windows_virtual_machine.backend.identity[0].principal_id
}
