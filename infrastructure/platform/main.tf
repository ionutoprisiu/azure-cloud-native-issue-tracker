resource "azurerm_resource_group" "platform" {
  name     = "rg-${var.project}-platform-${var.environment}-${var.region}-001"
  location = var.location
}

resource "azurerm_virtual_network" "platform" {
  for_each = var.vnet_address_spaces

  name                = "vnet-${var.project}-${each.key}-${var.environment}-${var.region}-001"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space       = [each.value]
}