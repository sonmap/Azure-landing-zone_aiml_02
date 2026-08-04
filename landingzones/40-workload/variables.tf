variable "subscription_id" { type = string }
variable "location" { type = string default = "koreacentral" }
variable "name_prefix" { type = string }
variable "private_endpoint_subnet_key" { type = string default = "private-endpoints" }
variable "tfstate_resource_group_name" { type = string }
variable "tfstate_storage_account_name" { type = string }
variable "tfstate_container_name" { type = string default = "tfstate" }
variable "tags" { type = map(string) default = {} }
