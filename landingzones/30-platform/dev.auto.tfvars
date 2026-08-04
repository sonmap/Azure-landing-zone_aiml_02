location                    = "koreacentral"
name_prefix                 = "aimldevkrc"
log_analytics_name          = "log-aiml-dev-krc"
private_endpoint_subnet_key = "private-endpoints"

tags = {
  environment = "dev"
  workload    = "aiml-landing-zone"
  layer       = "30-platform"
  managed_by  = "terraform"
}
