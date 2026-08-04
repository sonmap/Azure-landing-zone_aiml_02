variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name_prefix" { type = string }
variable "tenant_id" { type = string }
variable "private_endpoint_subnet_id" { type = string }
variable "private_dns_zone_ids" { type = map(string) }
variable "tags" { type = map(string); default = {} }

locals {
  compact = substr(lower(replace(var.name_prefix, "-", "")), 0, 18)
}

resource "azurerm_storage_account" "this" {
  name                            = "${local.compact}st"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  tags                            = var.tags
}

resource "azurerm_key_vault" "this" {
  name                          = substr("${var.name_prefix}-kv", 0, 24)
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  tags                          = var.tags
}

resource "azurerm_container_registry" "this" {
  name                          = "${local.compact}acr"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
  tags                          = var.tags
}

locals {
  endpoints = {
    blob = { resource_id = azurerm_storage_account.this.id, subresource = "blob", zone_key = "privatelink.blob.core.windows.net" }
    vault = { resource_id = azurerm_key_vault.this.id, subresource = "vault", zone_key = "privatelink.vaultcore.azure.net" }
    acr = { resource_id = azurerm_container_registry.this.id, subresource = "registry", zone_key = "privatelink.azurecr.io" }
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

output "storage_account_id" { value = azurerm_storage_account.this.id }
output "key_vault_id" { value = azurerm_key_vault.this.id }
output "container_registry_id" { value = azurerm_container_registry.this.id }