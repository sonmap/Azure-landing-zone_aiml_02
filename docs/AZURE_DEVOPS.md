# Azure DevOps 구성

## 배포 계층

| 순서 | 경로 | State Key | 역할 |
|---|---|---|---|
| 00 | `landingzones/00-bootstrap` | 로컬 bootstrap state | Terraform Backend용 Resource Group, Storage Account, Container 생성 |
| 10 | `landingzones/10-network` | `10-network.tfstate` | Hub VNet와 Private DNS 구성 |
| 20 | `landingzones/20-spoke` | `20-spoke.tfstate` | Spoke VNet, Subnet, Hub-Spoke Peering 구성 |
| 30 | `landingzones/30-platform` | `30-platform.tfstate` | Log Analytics, Storage, Key Vault, ACR 등 공통 플랫폼 구성 |
| 40 | `landingzones/40-workload` | `40-workload.tfstate` | Azure AI Services, AI Search, Cosmos DB 등 업무 워크로드 구성 |

## Azure DevOps 사전 구성

### Service Connection

Azure Resource Manager Service Connection을 Workload Identity Federation 방식으로 생성합니다.

예시 이름:

```text
sc-azure-aiml-dev
```

Service Principal 또는 Managed Identity에는 최소한 다음 권한이 필요합니다.

- 대상 Subscription 또는 Resource Group: `Contributor`
- Terraform State Storage Account: `Storage Blob Data Contributor`

### Variable Group

Library에서 다음 Variable Group을 생성합니다.

```text
vg-aiml-landing-zone
```

필수 변수:

| 변수 | 예시 |
|---|---|
| `azureServiceConnection` | `sc-azure-aiml-dev` |
| `subscriptionId` | Azure Subscription ID |
| `location` | `koreacentral` |
| `tfstateResourceGroup` | `rg-aiml-tfstate-krc` |
| `tfstateStorageAccount` | 전역 고유 Storage Account 이름 |
| `tfstateContainer` | `tfstate` |

### Environment 승인

Pipelines > Environments에서 다음 환경을 생성합니다.

```text
lz-bootstrap
lz-network_10
lz-spoke_20
lz-platform_30
lz-workload_40
```

운영 환경에서는 각 Apply Environment에 Approval Check를 설정하는 것을 권장합니다.

## 실행 순서

`azure-pipelines.yml`은 다음 순서로 실행됩니다.

```text
00 Bootstrap
  -> 10 Network Plan/Apply
    -> 20 Spoke Plan/Apply
      -> 30 Platform Plan/Apply
        -> 40 Workload Plan/Apply
```

00 Bootstrap은 Backend Storage가 아직 없기 때문에 로컬 state로 최초 실행됩니다. 이후 10~40은 Azure Storage Backend를 사용하며 각각 별도 state key로 관리됩니다.

## 운영 권장사항

- 00 Bootstrap은 최초 구축 후 일반 배포 Pipeline에서 분리하거나 수동 실행으로 전환합니다.
- PR에서는 Plan만 실행하고 main merge 후 Apply하도록 Pipeline 조건을 추가하는 것이 안전합니다.
- DEV, PRD, DR은 Variable Group과 tfvars를 분리합니다.
- Production Apply에는 Azure DevOps Environment Approval을 적용합니다.
- Backend Storage는 Public Network Access 제한과 Resource Lock 적용을 검토합니다.
