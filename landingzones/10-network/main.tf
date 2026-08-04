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

resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "hub_network" {
  source = "../../modules/network"

  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  address_space       = var.address_space
  subnets             = var.subnets
  tags                = var.tags
}

module "private_dns" {
  source = "../../modules/private-dns"

  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_id  = module.hub_network.vnet_id
  zone_names          = var.private_dns_zones
  tags                = var.tags
}

output "hub_resource_group_name" { value = azurerm_resource_group.hub.name }
output "hub_vnet_id" { value = module.hub_network.vnet_id }
output "hub_vnet_name" { value = module.hub_network.vnet_name }
output "private_dns_zone_ids" { value = module.private_dns.zone_ids }
