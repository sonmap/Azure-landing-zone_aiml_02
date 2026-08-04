# Azure AI/ML Landing Zone - Modular Terraform

This repository reorganizes `sonmap/azure-landing-zone_aiml_template` into small, reusable Terraform modules.

## Structure

```text
.
├── modules/
│   ├── network/
│   ├── private-dns/
│   ├── observability/
│   ├── shared-services/
│   └── ai-platform/
└── environments/
    └── standalone/
```

## Module responsibilities

| Module | Responsibility |
|---|---|
| `network` | VNet, subnets, NSGs and optional route table |
| `private-dns` | Private DNS zones and VNet links |
| `observability` | Log Analytics workspace |
| `shared-services` | Storage account, Key Vault and Container Registry |
| `ai-platform` | Azure AI Services, AI Search and Cosmos DB |

The environment layer composes modules and contains environment-specific values. Resource modules do not create resource groups and do not contain subscription-specific values.

## Quick start

```bash
cd environments/standalone
cp terraform.tfvars.example terraform.tfvars
az login
az account set --subscription <subscription-id>
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

## Design principles

- One module per infrastructure responsibility
- Resource group ownership stays in the environment layer
- Explicit module inputs and outputs
- Private access enabled by default for data and AI services
- Expensive optional ingress, firewall, bastion and VM components excluded from the baseline
- Naming and tags controlled by the environment layer

## Deployment order

Terraform resolves dependencies automatically, but the logical order is:

1. Resource group and Log Analytics
2. Network and private DNS
3. Shared services
4. AI platform services

## Notes

This is a cleaned baseline, not a line-by-line copy of the source repository. Add APIM, Application Gateway, Azure Firewall, Bastion, build VM and jump VM as separate optional modules when required.