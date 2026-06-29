variable "resource_group_name" {
  description = "The resource group name"
  type = string
  default = "rg-tf-lab"
}

variable "prefix" {
  description = "Prefix for all resources"
  type = string
}

variable "vm_name" {
  description = "Name of the VM"
  type = string
  default = "demo"
}

variable "vm_size" {
    description = "The size of the actual VM"
    type = string
  default = "Standard_B1s"
}

variable "admin_username" {
  description = "Administrator username for the Linux VM. Must not be a reserved Linux username."
  type        = string
  default     = "azureuser"
}

variable "vms" {
  description = "Map of VMs to create. The key becomes the VM role name (e.g. db, frontend, backend)."
  type = map(object({
    size       = string
    open_ports = list(string)
  }))

  default = {
    db = {
      size       = "Standard_B1s"
      open_ports = ["22"]
    }
    frontend = {
      size       = "Standard_B1s"
      open_ports = ["22"]
    }
    backend = {
      size       = "Standard_B1s"
      open_ports = ["22"]
    }
  }
}