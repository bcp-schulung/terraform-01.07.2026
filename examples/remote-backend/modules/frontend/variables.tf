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

variable "subnet_id" { # snet-web ID from networking module
  description = "Which subnet id to use"
  type        = string
}

variable "backend_fqdn" { # passed from backend module output
  description = "The FQDN of the backend module"
  type        = string
}

variable "tags" {
  description = "Tags for the module"
  type        = map(string)
  default     = {}
}
