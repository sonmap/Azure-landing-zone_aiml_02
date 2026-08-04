data "azurerm_client_config" "current" {}

locals {
  prefix = "${var.project_name}-${var.environment}"
  tags   = merge(var.tags, { environment = var.environment })

  private_dns_zones = toset([
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.azurecr.io",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.search.windows.net",
    "privatelink.documents.azure.com"
  ])
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

module "observability" {
  source              = "../../modules/observability"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  name                = "log-${local.prefix}"
  retention_in_days   = 30
  tags                = local.tags
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  name                = "vnet-${local.prefix}"
  address_space       = var.address_space
  tags                = local.tags

  subnets = {
    "snet-private-endpoints" = {
      address_prefixes                          = ["10.40.1.0/24"]
      private_endpoint_network_policies_enabled = false
    }
    "snet-container-apps" = {
      address_prefixes = ["10.40.2.0/23"]
      delegation = {
        name    = "container-apps"
        service = "Microsoft.App/environments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
    "snet-devops" = {
      address_prefixes = ["10.40.4.0/24"]
    }
  }
}

module "private_dns" {
  source              = "../../modules/private-dns"
  resource_group_name = azurerm_resource_group.this.name
  vnet_id             = module.network.vnet_id
  zone_names          = local.private_dns_zones
  tags                = local.tags
}

module "shared_services" {
  source                     = "../../modules/shared-services"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  name_prefix                = local.prefix
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  private_endpoint_subnet_id = module.network.subnet_ids["snet-private-endpoints"]
  private_dns_zone_ids       = module.private_dns.zone_ids
  tags                       = local.tags
}

module "ai_platform" {
  source                     = "../../modules/ai-platform"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  name_prefix                = local.prefix
  private_endpoint_subnet_id = module.network.subnet_ids["snet-private-endpoints"]
  private_dns_zone_ids       = module.private_dns.zone_ids
  tags                       = local.tags
}

output "resource_group_name" { value = azurerm_resource_group.this.name }
output "vnet_id" { value = module.network.vnet_id }
output "log_analytics_workspace_id" { value = module.observability.id }
output "storage_account_id" { value = module.shared_services.storage_account_id }
output "key_vault_id" { value = module.shared_services.key_vault_id }
output "container_registry_id" { value = module.shared_services.container_registry_id }
output "cognitive_account_id" { value = module.ai_platform.cognitive_account_id }
output "search_service_id" { value = module.ai_platform.search_service_id }
output "cosmosdb_account_id" { value = module.ai_platform.cosmosdb_account_id }