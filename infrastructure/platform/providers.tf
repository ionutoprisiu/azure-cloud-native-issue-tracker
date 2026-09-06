terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-cit-bootstrap-dev-neu-001"
    storage_account_name = "stcittfstatedev"
    container_name       = "tfstate"
    key                  = "platform.tfstate"
  }
}

provider "azurerm" {
  features {}
}