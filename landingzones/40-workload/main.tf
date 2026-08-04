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

data "terraform_remote_state" "spoke" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.tfstate_container_name
    key                  = "20-spoke.tfstate"
    use_azuread_auth      = true
  }
}

data "terraform_remote_state" "platform" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.tfstate_container_name
    key                  = "30-platform.tfstate"
    use_azuread_auth      = true
  }
}

module "ai_platform" {
  source = "../../modules/ai-platform"

  resource_group_name        = data.terraform_remote_state.spoke.outputs.spoke_resource_group_name
  location                   = var.location
  name_prefix                = var.name_prefix
  private_endpoint_subnet_id = data.terraform_remote_state.spoke.outputs.subnet_ids[var.private_endpoint_subnet_key]
  tags                       = var.tags
}

output "ai_services_id" { value = module.ai_platform.ai_services_id }
output "ai_search_id" { value = module.ai_platform.ai_search_id }
output "cosmosdb_id" { value = module.ai_platform.cosmosdb_id }
