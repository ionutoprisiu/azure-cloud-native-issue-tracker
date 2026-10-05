variable "project" {
  type        = string
  description = "Project name."
}

variable "environment" {
  type        = string
  description = "Deployment environment."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "postgresql_version" {
  type        = string
  description = "PostgreSQL server version."
}

variable "postgresql_sku_name" {
  type        = string
  description = "PostgreSQL Flexible Server SKU."
}

variable "postgresql_storage_mb" {
  type        = number
  description = "PostgreSQL storage size in MB."
}

variable "postgresql_admin_login" {
  type        = string
  description = "PostgreSQL administrator username."
}

variable "postgresql_admin_password" {
  type        = string
  description = "PostgreSQL administrator password."
  sensitive   = true
}

variable "postgresql_database_name" {
  type        = string
  description = "Application database name."
}