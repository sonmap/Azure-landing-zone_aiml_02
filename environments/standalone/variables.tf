variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "location" {
  type    = string
  default = "koreacentral"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "aiml-lz"
}

variable "address_space" {
  type    = list(string)
  default = ["10.40.0.0/16"]
}

variable "tags" {
  type = map(string)
  default = {
    workload    = "ai-ml"
    managed_by  = "terraform"
    environment = "dev"
  }
}