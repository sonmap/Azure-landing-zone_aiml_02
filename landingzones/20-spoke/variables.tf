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
variable "tfstate_resource_group_name" { type = string }
variable "tfstate_storage_account_name" { type = string }
variable "tfstate_container_name" { type = string default = "tfstate" }
variable "tags" { type = map(string) default = {} }
