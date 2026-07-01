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

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
