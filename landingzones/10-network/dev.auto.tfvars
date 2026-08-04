location            = "koreacentral"
resource_group_name = "rg-aiml-hub-dev-krc"
vnet_name           = "vnet-aiml-hub-dev-krc"
address_space       = ["10.10.0.0/16"]

subnets = {
  shared = {
    address_prefixes = ["10.10.1.0/24"]
  }
  dns = {
    address_prefixes = ["10.10.2.0/24"]
  }
}

private_dns_zones = [
  "privatelink.blob.core.windows.net",
  "privatelink.vaultcore.azure.net",
  "privatelink.azurecr.io",
  "privatelink.cognitiveservices.azure.com",
  "privatelink.search.windows.net",
  "privatelink.documents.azure.com"
]

tags = {
  environment = "dev"
  workload    = "aiml-landing-zone"
  layer       = "10-network"
  managed_by  = "terraform"
}
