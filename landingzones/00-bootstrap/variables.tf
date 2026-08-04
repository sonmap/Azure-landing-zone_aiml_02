variable "subscription_id" { type = string }
variable "location" { type = string default = "koreacentral" }
variable "tfstate_resource_group_name" { type = string }
variable "tfstate_storage_account_name" { type = string }
variable "tfstate_container_name" { type = string default = "tfstate" }
variable "tags" { type = map(string) default = {} }
