locals {
  region = "frc"

  container_app_environments = toset([
    "frontend",
    "backend"
  ])

  container_apps = {
    frontend = {
      image            = "hello:latest"
      target_port      = 80
      external_enabled = true
    }

    backend = {
      image            = "backend:latest"
      target_port      = 8000
      external_enabled = true
    }
  }
}