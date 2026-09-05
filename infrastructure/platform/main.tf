resource "azurerm_resource_group" "platform" {
  name     = "rg-${var.project}-platform-${var.environment}-${local.region}-001"
  location = var.location
}

resource "azurerm_virtual_network" "platform" {
  for_each = var.vnet_address_spaces

  name                = "vnet-${var.project}-${each.key}-${var.environment}-${local.region}-001"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space       = [each.value]
}

resource "azurerm_subnet" "platform" {
  for_each = var.subnets

  name                 = "snet-${var.project}-${each.key}-${var.environment}-${local.region}-001"
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
  for_each = local.peerings

  name                      = "peer-${each.value.source}-to-${each.value.target}"
  resource_group_name       = azurerm_resource_group.platform.name
  virtual_network_name      = azurerm_virtual_network.platform[each.value.source].name
  remote_virtual_network_id = azurerm_virtual_network.platform[each.value.target].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_network_interface" "nva" {
  name                = "nic-${var.project}-nva-${var.environment}-${local.region}-001"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.platform["hub-nva"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.nva_private_ip
  }
}

resource "azurerm_linux_virtual_machine" "nva" {
  name                = "vm-${var.project}-nva-${var.environment}-${local.region}-001"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  size                = var.nva_vm_size
  admin_username      = var.nva_admin_username

  network_interface_ids = [azurerm_network_interface.nva.id]

  admin_ssh_key {
    username   = var.nva_admin_username
    public_key = var.nva_ssh_public_key
  }

  custom_data = filebase64("${path.module}/cloud-init/nva.yaml")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

resource "azurerm_route_table" "platform" {
  for_each = local.route_tables

  name                = "rt-${var.project}-${each.key}-${var.environment}-${local.region}-001"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
}

resource "azurerm_route" "platform" {
  for_each = local.routes

  name                = "route-to-${each.value.target}"
  resource_group_name = azurerm_resource_group.platform.name
  route_table_name    = azurerm_route_table.platform[each.value.source].name

  address_prefix         = var.vnet_address_spaces[each.value.target]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.nva_private_ip
}

resource "azurerm_subnet_route_table_association" "platform" {
  for_each = local.route_tables

  subnet_id      = azurerm_subnet.platform[each.key].id
  route_table_id = azurerm_route_table.platform[each.key].id
}



