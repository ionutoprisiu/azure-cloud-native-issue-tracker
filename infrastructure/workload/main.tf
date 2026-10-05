data "terraform_remote_state" "platform" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-cit-bootstrap-dev-neu-001"
    storage_account_name = "stcittfstatedev"
    container_name       = "tfstate"
    key                  = "platform.tfstate"
  }
}

data "terraform_remote_state" "data" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-cit-bootstrap-dev-neu-001"
    storage_account_name = "stcittfstatedev"
    container_name       = "tfstate"
    key                  = "data.tfstate"
  }
}

resource "azurerm_resource_group" "workload" {
  name     = "rg-${var.project}-workload-${var.environment}-${local.region}-001"
  location = var.location
}

resource "azurerm_container_app_environment" "workload" {
  for_each = local.container_app_environments

  name                     = "cae-${var.project}-${each.key}-${var.environment}-${local.region}-001"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.workload.name
  infrastructure_subnet_id = data.terraform_remote_state.platform.outputs.subnet_ids[each.key]

  lifecycle {
    ignore_changes = [workload_profile]
  }
}

resource "azurerm_user_assigned_identity" "workload" {
  for_each = local.container_app_environments

  name                = "id-${var.project}-${each.key}-${var.environment}-${local.region}-001"
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each = local.container_app_environments

  scope                = data.terraform_remote_state.platform.outputs.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.workload[each.key].principal_id
}

resource "azurerm_container_app" "frontend" {
  name                         = "ca-${var.project}-frontend-${var.environment}-${local.region}-001"
  container_app_environment_id = azurerm_container_app_environment.workload["frontend"].id
  resource_group_name          = azurerm_resource_group.workload.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.workload["frontend"].id
    ]
  }

  registry {
    server   = data.terraform_remote_state.platform.outputs.acr_login_server
    identity = azurerm_user_assigned_identity.workload["frontend"].id
  }

  template {
    container {
      name   = "frontend"
      image  = "${data.terraform_remote_state.platform.outputs.acr_login_server}/${local.frontend_image}"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [
    azurerm_role_assignment.acr_pull["frontend"]
  ]
}

resource "azurerm_container_app" "backend" {
  name                         = "ca-${var.project}-backend-${var.environment}-${local.region}-001"
  container_app_environment_id = azurerm_container_app_environment.workload["backend"].id
  resource_group_name          = azurerm_resource_group.workload.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.workload["backend"].id
    ]
  }

  registry {
    server   = data.terraform_remote_state.platform.outputs.acr_login_server
    identity = azurerm_user_assigned_identity.workload["backend"].id
  }

  template {
    container {
      name   = "backend"
      image  = "${data.terraform_remote_state.platform.outputs.acr_login_server}/${local.backend_image}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "POSTGRES_HOST"
        value = data.terraform_remote_state.data.outputs.postgresql_fqdn
      }

      env {
        name  = "POSTGRES_DB"
        value = data.terraform_remote_state.data.outputs.postgresql_database_name
      }
    }


  }

  ingress {
    external_enabled = true
    target_port      = 8000

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [
    azurerm_role_assignment.acr_pull["backend"]
  ]
}