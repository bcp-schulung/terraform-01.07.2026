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

variable "trusted_rdp_cidr" {
  type        = string
  description = "CIDR block allowed to RDP to the backend VM (e.g. \"203.0.113.10/32\")."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
