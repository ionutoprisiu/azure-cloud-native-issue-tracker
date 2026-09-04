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

resource "azurerm_subnet" "platform" {
  for_each = var.subnets

  name                 = "snet-${var.project}-${each.key}-${var.environment}-${var.region}-001"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform[each.value.vnet_key].name
  address_prefixes     = [each.value.address_prefix]

  dynamic "delegation" {
    for_each = each.value.delegate_to_container_apps ? [1] : []

    content {
      name = "container-apps"

      service_delegation {
        name    = "Microsoft.App/environments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

resource "azurerm_virtual_network_peering" "platform" {
  for_each = var.peerings

  name                      = "peer-${each.value.source}-to-${each.value.target}"
  resource_group_name       = azurerm_resource_group.platform.name
  virtual_network_name      = azurerm_virtual_network.platform[each.value.source].name
  remote_virtual_network_id = azurerm_virtual_network.platform[each.value.target].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
