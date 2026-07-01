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
