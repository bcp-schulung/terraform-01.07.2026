terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name  = "rg-tf-backend"
    storage_account_name = "sttflabbackend"
    container_name       = "tfstate"
    use_azuread_auth     = true
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
