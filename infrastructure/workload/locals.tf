locals {
  region = "frc"

  container_app_environments = toset([
    "frontend",
    "backend"
  ])

  frontend_image = "frontend:latest"
  backend_image  = "backend:latest"
}