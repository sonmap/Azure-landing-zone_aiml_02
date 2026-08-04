variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name_prefix" { type = string }
variable "private_endpoint_subnet_id" { type = string }
variable "private_dns_zone_ids" { type = map(string) }
variable "tags" { type = map(string); default = {} }

locals {
  compact = substr(lower(replace(var.name_prefix, "-", "")), 0, 18)
}

resource "azurerm_cognitive_account" "ai" {
  name                          = "${var.name_prefix}-ai"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "AIServices"
  sku_name                      = "S0"
  custom_subdomain_name         = "${local.compact}ai"
  public_network_access_enabled = false
  local_auth_enabled            = false
  tags                          = var.tags
}

resource "azurerm_search_service" "this" {
  name                          = "${var.name_prefix}-search"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "basic"
  public_network_access_enabled = false
  local_authentication_enabled  = false
  semantic_search_sku           = "free"
  tags                          = var.tags
}

resource "azurerm_cosmosdb_account" "this" {
  name                          = "${var.name_prefix}-cosmos"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  public_network_access_enabled = false
  local_authentication_disabled = true
  tags                          = var.tags

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

locals {
  endpoints = {
    cognitive = { resource_id = azurerm_cognitive_account.ai.id, subresource = "account", zone_key = "privatelink.cognitiveservices.azure.com" }
    search = { resource_id = azurerm_search_service.this.id, subresource = "searchService", zone_key = "privatelink.search.windows.net" }
    cosmos = { resource_id = azurerm_cosmosdb_account.this.id, subresource = "Sql", zone_key = "privatelink.documents.azure.com" }
  }
}

resource "azurerm_private_endpoint" "this" {
  for_each            = local.endpoints
  name                = "pe-${var.name_prefix}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${each.key}"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = [each.value.subresource]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids[each.value.zone_key]]
  }
}

output "cognitive_account_id" { value = azurerm_cognitive_account.ai.id }
output "search_service_id" { value = azurerm_search_service.this.id }
output "cosmosdb_account_id" { value = azurerm_cosmosdb_account.this.id }