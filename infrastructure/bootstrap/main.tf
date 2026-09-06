resource "azurerm_resource_group" "bootstrap" {
  name     = "rg-${var.project}-bootstrap-${var.environment}-${var.region}-001"
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "st${var.project}tfstate${var.environment}"
  resource_group_name      = azurerm_resource_group.bootstrap.name
  location                 = azurerm_resource_group.bootstrap.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}