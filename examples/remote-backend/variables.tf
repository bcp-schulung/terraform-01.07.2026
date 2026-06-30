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
  description = "Administrator username for the backend Windows VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Administrator password for the backend Windows VM (min 12 chars, must include upper, lower, digit, special)"
  type        = string
  sensitive   = true
}
