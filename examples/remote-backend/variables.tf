variable "resource_group_name" {
  description = "Name of the existing resource group to look up"
  type        = string
  default     = "rg-tf-lab"
}

variable "prefix" {
  description = "Short prefix used to name all resources"
  type        = string
  default     = "lab"
}

variable "admin_username" {
  description = "Administrator username for the backend Windows VM."
  type        = string
  default     = "azureuser"
}

variable "trusted_rdp_cidr" {
  description = "CIDR block allowed to RDP to the backend VM (e.g. \"203.0.113.10/32\")."
  type        = string
}

variable "sql_admin_username" {
  description = "SQL Server administrator login name."
  type        = string
}

variable "aad_admin_object_id" {
  description = "Azure AD object ID of the SQL Azure AD administrator."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
