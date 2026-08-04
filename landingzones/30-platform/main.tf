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

module "observability" {
  source = "../../modules/observability"

  name                = var.log_analytics_name
  resource_group_name = data.terraform_remote_state.spoke.outputs.spoke_resource_group_name
  location            = var.location
  tags                = var.tags
}

module "shared_services" {
  source = "../../modules/shared-services"

  resource_group_name = data.terraform_remote_state.spoke.outputs.spoke_resource_group_name
  location            = var.location
  name_prefix         = var.name_prefix
  private_endpoint_subnet_id = data.terraform_remote_state.spoke.outputs.subnet_ids[var.private_endpoint_subnet_key]
  tags                = var.tags
}

output "log_analytics_workspace_id" { value = module.observability.workspace_id }
output "storage_account_id" { value = module.shared_services.storage_account_id }
output "key_vault_id" { value = module.shared_services.key_vault_id }
output "container_registry_id" { value = module.shared_services.container_registry_id }
