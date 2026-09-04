terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-cit-bootstrap-dev-swc-001"
    storage_account_name = "stcittfstatedev001"
    container_name       = "tfstate"
    key                  = "platform.tfstate"
  }
}

provider "azurerm" {
  features {}
}