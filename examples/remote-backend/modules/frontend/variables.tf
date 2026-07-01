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
  description = "Resource ID of snet-web (from networking module)."
}

variable "agw_subnet_id" {
  type        = string
  description = "Resource ID of snet-agw (from networking module), used for the Application Gateway."
}

variable "backend_fqdn" {
  type        = string
  description = "Private IP or FQDN of the backend tier."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
