project     = "cit"
environment = "dev"
location    = "France Central"

vnet_address_spaces = {
  hub      = "10.0.0.0/24"
  frontend = "10.0.1.0/24"
  backend  = "10.0.2.0/24"
  data     = "10.0.3.0/24"
}

subnets = {
  hub-nva = {
    vnet_key                   = "hub"
    address_prefix             = "10.0.0.0/27"
    delegate_to_container_apps = false
  }

  frontend = {
    vnet_key                   = "frontend"
    address_prefix             = "10.0.1.0/27"
    delegate_to_container_apps = true
  }

  backend = {
    vnet_key                   = "backend"
    address_prefix             = "10.0.2.0/27"
    delegate_to_container_apps = true
  }

  data = {
    vnet_key                   = "data"
    address_prefix             = "10.0.3.0/27"
    delegate_to_container_apps = false
  }
}

nva_private_ip     = "10.0.0.4"
nva_vm_size        = "Standard_D2s_v6"
nva_admin_username = "azureuser"
nva_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEu4ql2q/CHMIiF29rUh9OiqT9ACw11Avk4Zg0lrKQ7 ionut@Ionuts-MacBook-Pro.local"