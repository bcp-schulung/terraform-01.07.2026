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
