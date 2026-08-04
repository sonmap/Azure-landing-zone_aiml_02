terraform {
  required_version = ">= 1.6.0"
  backend "azurerm" {}
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.tfstate_container_name
    key                  = "10-network.tfstate"
    use_azuread_auth      = true
  }
}

resource "azurerm_resource_group" "spoke" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "spoke_network" {
  source = "../../modules/network"

  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.spoke.name
  location            = var.location
  address_space       = var.address_space
  subnets             = var.subnets
  tags                = var.tags
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-${var.vnet_name}-to-hub"
  resource_group_name       = azurerm_resource_group.spoke.name
  virtual_network_name      = module.spoke_network.vnet_name
  remote_virtual_network_id = data.terraform_remote_state.hub.outputs.hub_vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  provider                  = azurerm
  name                      = "peer-hub-to-${var.vnet_name}"
  resource_group_name       = data.terraform_remote_state.hub.outputs.hub_resource_group_name
  virtual_network_name      = data.terraform_remote_state.hub.outputs.hub_vnet_name
  remote_virtual_network_id = module.spoke_network.vnet_id
  allow_forwarded_traffic   = true
}

output "spoke_resource_group_name" { value = azurerm_resource_group.spoke.name }
output "spoke_vnet_id" { value = module.spoke_network.vnet_id }
output "subnet_ids" { value = module.spoke_network.subnet_ids }
