variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group."
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
}

variable "prefix" {
  type        = string
  description = "Prefix applied to all resource names."
}

variable "subnet_id" {
  type        = string
  description = "Resource ID of snet-backend (from networking module)."
}

variable "admin_username" {
  type        = string
  description = "Local administrator username for the Windows VM."
}

variable "key_vault_id" {
  type        = string
  description = "Resource ID of the Key Vault that holds the VM admin password secret."
}

variable "trusted_rdp_cidr" {
  type        = string
  description = "CIDR block allowed to RDP to the VM (e.g. \"203.0.113.10/32\")."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
