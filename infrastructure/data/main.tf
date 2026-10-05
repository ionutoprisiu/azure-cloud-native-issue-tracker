data "terraform_remote_state" "platform" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-cit-bootstrap-dev-neu-001"
    storage_account_name = "stcittfstatedev"
    container_name       = "tfstate"
    key                  = "platform.tfstate"
  }
}

resource "azurerm_resource_group" "data" {
  name     = "rg-${var.project}-data-${var.environment}-frc-001"
  location = var.location
}

resource "azurerm_postgresql_flexible_server" "data" {
  name                = "psql-${var.project}-${var.environment}-frc-001"
  resource_group_name = azurerm_resource_group.data.name
  location            = azurerm_resource_group.data.location

  version = var.postgresql_version

  administrator_login    = var.postgresql_admin_login
  administrator_password = var.postgresql_admin_password

  sku_name   = var.postgresql_sku_name
  storage_mb = var.postgresql_storage_mb

  public_network_access_enabled = false
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = var.postgresql_database_name
  server_id = azurerm_postgresql_flexible_server.data.id
}

resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.data.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_backend" {
  name                = "link-postgresql-backend"
  private_dns_zone_id = azurerm_private_dns_zone.postgresql.id
  virtual_network_id  = data.terraform_remote_state.platform.outputs.vnet_ids["backend"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_data" {
  name                = "link-postgresql-data"
  private_dns_zone_id = azurerm_private_dns_zone.postgresql.id
  virtual_network_id  = data.terraform_remote_state.platform.outputs.vnet_ids["data"]
}

resource "azurerm_private_endpoint" "postgresql" {
  name                = "pe-psql-${var.project}-${var.environment}-frc-001"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  subnet_id           = data.terraform_remote_state.platform.outputs.subnet_ids["data"]

  private_service_connection {
    name                           = "psc-psql-${var.project}-${var.environment}-frc-001"
    private_connection_resource_id = azurerm_postgresql_flexible_server.data.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "postgresql"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgresql.id]
  }
}