output "resource_group_name" {
  description = "Name of the platform resource group."
  value       = azurerm_resource_group.platform.name
}

output "vnet_ids" {
  description = "IDs of the platform virtual networks."

  value = {
    for key, vnet in azurerm_virtual_network.platform :
    key => vnet.id
  }
}

output "subnet_ids" {
  description = "IDs of the platform subnets."

  value = {
    for key, subnet in azurerm_subnet.platform :
    key => subnet.id
  }
}

output "acr_id" {
  description = "Resource ID of the Azure Container Registry."
  value       = azurerm_container_registry.platform.id
}

output "acr_name" {
  description = "Name of the Azure Container Registry."
  value       = azurerm_container_registry.platform.name
}

output "acr_login_server" {
  description = "Login server of Azure Container Registry."
  value       = azurerm_container_registry.platform.login_server
}

output "key_vault_id" {
  description = "Resource ID of the platform Key Vault."
  value       = azurerm_key_vault.platform.id
}

output "key_vault_name" {
  description = "Name of the platform Key Vault."
  value       = azurerm_key_vault.platform.name
}

output "key_vault_uri" {
  description = "URI of the platform Key Vault."
  value       = azurerm_key_vault.platform.vault_uri
}