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

variable "trusted_rdp_cidr" { # e.g. "203.0.113.10/32"
  description = "Explict access for ip / range"
  type        = string
}
