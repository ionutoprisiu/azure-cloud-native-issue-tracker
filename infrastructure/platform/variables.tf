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

variable "nva_private_ip" {
  description = "Static private IP address of the network virtual appliance."
  type        = string
}

variable "nva_vm_size" {
  description = "Size of the NVA virtrual machine."
  type        = string
}

variable "nva_admin_username" {
  description = "Administrator username for the NVA virtual machine."
  type        = string
}

variable "nva_ssh_public_key" {
  description = "SSH public key used to access the NVA virtual machine."
  type        = string
}