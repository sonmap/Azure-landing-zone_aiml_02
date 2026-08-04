variable "subscription_id" { type = string }
variable "location" { type = string default = "koreacentral" }
variable "resource_group_name" { type = string }
variable "vnet_name" { type = string }
variable "address_space" { type = list(string) }
variable "subnets" {
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name = string
      service_delegation_name = string
      actions = list(string)
    }))
  }))
}
variable "private_dns_zones" { type = set(string) default = [] }
variable "tags" { type = map(string) default = {} }
