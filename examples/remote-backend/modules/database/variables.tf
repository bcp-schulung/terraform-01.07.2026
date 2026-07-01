variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the resource group"
  type        = string
}

variable "prefix" {
  description = "Short prefix used to name all resources of this module"
  type        = string
}

variable "tags" {
  description = "Tags for the module"
  type        = map(string)
  default     = {}
}

variable "subnet_db_id" {
  description = "Which subnet id to use"
  type        = string
}

variable "app_vnet_id" {
  description = "Id for the vnet of the backend"
  type        = string
}

variable "sql_admin_username" {
  description = "sql admin username"
  type        = string
}

variable "aad_admin_object_id" { # your own Azure AD object ID
  description = "AAD object id for admin"
  type        = string
}
