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

variable "subnet_db_id" {
  type        = string
  description = "Resource ID of snet-db (from networking module)."
}

variable "app_vnet_id" {
  type        = string
  description = "Resource ID of the App VNet (for the private DNS zone link)."
}

variable "sql_admin_username" {
  type        = string
  description = "SQL Server administrator login name."
}

variable "aad_admin_object_id" {
  type        = string
  description = "Azure AD object ID of the SQL Azure AD administrator."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
