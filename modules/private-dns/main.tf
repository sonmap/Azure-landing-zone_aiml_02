variable "resource_group_name" { type = string }
variable "vnet_id" { type = string }
variable "zone_names" { type = set(string) }
variable "tags" { type = map(string); default = {} }

resource "azurerm_private_dns_zone" "this" {
  for_each            = var.zone_names
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.zone_names
  name                  = "link-${replace(each.value, ".", "-")}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = var.vnet_id
  registration_enabled = false
  tags                  = var.tags
}

output "zone_ids" { value = { for k, v in azurerm_private_dns_zone.this : k => v.id } }
output "zone_names" { value = { for k, v in azurerm_private_dns_zone.this : k => v.name } }