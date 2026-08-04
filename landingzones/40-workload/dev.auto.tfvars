location                    = "koreacentral"
name_prefix                 = "aimldevkrc"
private_endpoint_subnet_key = "private-endpoints"

tags = {
  environment = "dev"
  workload    = "aiml-landing-zone"
  layer       = "40-workload"
  managed_by  = "terraform"
}
