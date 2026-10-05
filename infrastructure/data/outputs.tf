output "resource_group_name" {
  description = "Name of the data resource group."
  value       = azurerm_resource_group.data.name
}

output "postgresql_server_id" {
  description = "Resource ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.data.id
}

output "postgresql_fqdn" {
  description = "Fully qualified domain name of the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.data.fqdn
}

output "postgresql_database_name" {
  description = "Name of the application PostgreSQL database."
  value       = azurerm_postgresql_flexible_server_database.app.name
}

output "private_endpoint_id" {
  description = "Resource ID of the PostgreSQL Private Endpoint."
  value       = azurerm_private_endpoint.postgresql.id
}

output "private_dns_zone_id" {
  description = "Resource ID of the PostgreSQL Private DNS Zone."
  value       = azurerm_private_dns_zone.postgresql.id
}