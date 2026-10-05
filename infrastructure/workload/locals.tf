locals {
  region = "frc"

  container_app_environments = toset([
    "frontend",
    "backend"
  ])

  frontend_image = "hello:latest"
  backend_image  = "backend:latest"
}