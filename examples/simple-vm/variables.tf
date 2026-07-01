variable "resource_group_name" {
  description = "The resource group name"
  type        = string
  default     = "rg-tf-lab"
}

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "demo"
}

variable "vm_size" {
  description = "The size of the actual VM"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Administrator username for the Linux VM. Must not be a reserved Linux username."
  type        = string
  default     = "azureuser"
}