locals {
  region = "swc"

  peerings = {
    hub_to_frontend = {
      source = "hub"
      target = "frontend"
    }

    frontend_to_hub = {
      source = "frontend"
      target = "hub"
    }

    hub_to_backend = {
      source = "hub"
      target = "backend"
    }

    backend_to_hub = {
      source = "backend"
      target = "hub"
    }

    hub_to_data = {
      source = "hub"
      target = "data"
    }

    data_to_hub = {
      source = "data"
      target = "hub"
    }
  }

  route_tables = toset([
    "frontend",
    "backend",
    "data"
  ])

  routes = {
    frontend_to_backend = {
      source = "frontend"
      target = "backend"
    }

    backend_to_frontend = {
      source = "backend"
      target = "frontend"
    }

    backend_to_data = {
      source = "backend"
      target = "data"
    }

    data_to_backend = {
      source = "data"
      target = "backend"
    }
  }
}