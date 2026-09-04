variable "project" {
  description = "Short project identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "region" {
  description = "Short region code used in resource naming."
  type        = string
}

variable "vnet_address_spaces" {
  description = "Address spaces for the platform virtual networks."
  type        = map(string)
}

variable "subnets" {
  description = "Configuration for platform subnets."

  type = map(object({
    vnet_key                   = string
    address_prefix             = string
    delegate_to_container_apps = bool
  }))
}