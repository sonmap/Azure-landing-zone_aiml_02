location            = "koreacentral"
resource_group_name = "rg-aiml-spoke-dev-krc"
vnet_name           = "vnet-aiml-spoke-dev-krc"
address_space       = ["10.20.0.0/16"]

subnets = {
  workload = {
    address_prefixes = ["10.20.1.0/24"]
  }
  private-endpoints = {
    address_prefixes = ["10.20.2.0/24"]
  }
  container-apps = {
    address_prefixes = ["10.20.4.0/23"]
    delegation = {
      name                    = "container-apps"
      service_delegation_name = "Microsoft.App/environments"
      actions                 = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

tags = {
  environment = "dev"
  workload    = "aiml-landing-zone"
  layer       = "20-spoke"
  managed_by  = "terraform"
}
