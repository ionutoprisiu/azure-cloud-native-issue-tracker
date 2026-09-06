data "terraform_remote_state" "platform" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-cit-bootstrap-dev-neu-001"
    storage_account_name = "stcittfstatedev"
    container_name       = "tfstate"
    key                  = "platform.tfstate"
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

resource "azurerm_container_app" "workload" {
  for_each = local.container_apps

  name                         = "ca-${var.project}-${each.key}-${var.environment}-${local.region}-001"
  container_app_environment_id = azurerm_container_app_environment.workload[each.key].id
  resource_group_name          = azurerm_resource_group.workload.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.workload[each.key].id
    ]
  }

  registry {
    server   = data.terraform_remote_state.platform.outputs.acr_login_server
    identity = azurerm_user_assigned_identity.workload[each.key].id
  }

  template {
    container {
      name   = each.key
      image  = "${data.terraform_remote_state.platform.outputs.acr_login_server}/${each.value.image}"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled = each.value.external_enabled
    target_port      = each.value.target_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [
    azurerm_role_assignment.acr_pull
  ]
}
