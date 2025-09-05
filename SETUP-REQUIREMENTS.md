# Azure Enterprise Learning - Setup Requirements

## Overview

This document outlines the complete setup requirements for the Azure Enterprise Learning project, focusing on the enterprise-grade Azure Container Registry (ACR) pattern with environment tag promotion strategy.

## Prerequisites

### Azure Subscription

- **Active Azure Subscription:** `7a5bee06-2155-4808-885b-ba1c53c04dbd`
- **Budget:** $200 Azure credit, target $100 total spend
- **Cost Control:** Daily destroy/rebuild pattern for learning

### Development Environment

#### Required Software

```bash
# Azure CLI (latest)
az --version  # Should be 2.50.0+

# Terraform (1.5+)
terraform --version

# Docker (for container operations)
docker --version

# kubectl (Kubernetes CLI)
kubectl version --client

# Git (for source control)
git --version
```

#### VS Code Extensions (Recommended)

- Azure Tools for VS Code
- Terraform Extension for VS Code
- Kubernetes Extension for VS Code
- Docker Extension for VS Code

## Azure Service Principal Configuration

### Critical Setup: Terraform Service Principal

**Service Principal ID:** `b5422da7-4709-4cdd-9ca4-47ea063df820`  
**Name:** `terraform-sp`

#### Required Permissions

**For Learning Environment (Temporary):**

```bash
# Grant Owner role for learning (enables role assignments)
az role assignment create \
  --assignee b5422da7-4709-4cdd-9ca4-47ea063df820 \
  --role Owner \
  --scope /subscriptions/7a5bee06-2155-4808-885b-ba1c53c04dbd
```

**Why Owner Role is Needed:**
- AKS-ACR integration requires `AcrPull` role assignments
- Role assignments need `User Access Administrator` or `Owner` permissions
- Contributor role is insufficient for RBAC operations

#### Enterprise Production Pattern

For production environments, use separate service principals:

```bash
# Infrastructure Service Principal
az ad sp create-for-rbac \
  --name "terraform-infrastructure-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/7a5bee06-2155-4808-885b-ba1c53c04dbd"

# RBAC Service Principal  
az ad sp create-for-rbac \
  --name "terraform-rbac-sp" \
  --role "User Access Administrator" \
  --scopes "/subscriptions/7a5bee06-2155-4808-885b-ba1c53c04dbd"
```

#### Environment Variables

```bash
# Set Terraform authentication
export ARM_CLIENT_ID="b5422da7-4709-4cdd-9ca4-47ea063df820"
export ARM_CLIENT_SECRET="<service-principal-secret>"
export ARM_SUBSCRIPTION_ID="7a5bee06-2155-4808-885b-ba1c53c04dbd"
export ARM_TENANT_ID="<tenant-id>"
```

## Terraform Backend Configuration

### Azure Storage Account

**Pre-requisite:** Storage account for remote state management

```bash
# Create resource group for Terraform state
az group create \
  --name tfstate-rg \
  --location "East US"

# Create storage account (unique name required)
az storage account create \
  --name tfstatec18b586c \
  --resource-group tfstate-rg \
  --location "East US" \
  --sku Standard_LRS

# Create container for state files
az storage container create \
  --name tfstate \
  --account-name tfstatec18b586c
```

### Backend Configuration

```hcl
# terraform/backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatec18b586c"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

## Container Registry Requirements

### Enterprise ACR Pattern

**Design Decision:** Single shared ACR with environment tag promotion

#### ACR Configuration

```hcl
# ACR Resource (inline in dev environment)
resource "azurerm_container_registry" "shared" {
  name                = "sharedlearnacr"
  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location
  sku                 = "Basic"        # Cost optimization: ~$5/month
  admin_enabled       = false          # Use managed identity instead

  tags = {
    Environment = "shared"
    Project     = "azure-enterprise-learning"
    CostCenter  = "learning"
  }
}
```

#### Container Naming Convention

```text
Registry: sharedlearnacr.azurecr.io
├── api-service-1/
│   ├── v1.2.3-commit-abc123    # Immutable build artifact
│   ├── dev-ready               # Environment promotion tag
│   ├── staging-ready           # Manual approval gate
│   └── prod-ready              # Production ready
├── api-service-2/
└── web-app/
```

## AKS Configuration Requirements

### Cluster Specifications

#### Development Environment

```hcl
# Minimal viable configuration for learning
default_node_pool {
  name            = "default"
  node_count      = 1              # Cost optimization
  vm_size         = "Standard_B2s" # Cheapest viable size
  os_disk_size_gb = 30            # Minimal disk
  max_pods        = 110           # Default
}
```

#### Network Configuration

```hcl
# Network settings
network_profile {
  network_plugin    = "azure"
  dns_service_ip    = "10.1.0.10"
  service_cidr      = "10.1.0.0/16"    # Separate from VNet CIDR
  docker_bridge_cidr = "172.17.0.1/16"
}
```

### AKS-ACR Integration

**Critical:** Role assignment for container image access

```hcl
# AKS kubelet identity needs AcrPull permission
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.shared.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity[0].object_id
}
```

## Module Architecture

### Reusable Modules (terraform/modules/)

#### Networking Module

**Justification:** High reuse (3+ environments), complex configuration

```text
terraform/modules/networking/
├── main.tf       # VNet, subnets, NSGs
├── variables.tf  # Configurable CIDR blocks
├── outputs.tf    # Network references
└── README.md     # Module documentation
```

#### AKS Module

**Justification:** Complex multi-resource setup, environment reuse

```text
terraform/modules/aks/
├── main.tf       # Cluster, node pools, monitoring
├── variables.tf  # Node configuration, RBAC settings
├── outputs.tf    # Cluster credentials, kubelet identity
└── README.md     # Module documentation
```

### Inline Resources (terraform/environments/*/main.tf)

#### Resources Kept Inline

- **ACR:** Simple configuration, shared across environments
- **PostgreSQL:** Environment-specific sizing requirements
- **Key Vault:** Per-environment secrets, minimal complexity

## Environment Structure

### Directory Organization

```text
terraform/
├── backend.tf                    # Shared backend configuration
├── modules/
│   ├── networking/              # Reusable VNet module
│   └── aks/                     # Reusable AKS module
└── environments/
    ├── dev/
    │   ├── main.tf              # Dev orchestration
    │   ├── variables.tf         # Dev-specific variables
    │   ├── outputs.tf           # Dev outputs
    │   └── terraform.tfvars     # Dev values
    ├── staging/                 # Future implementation
    └── prod/                    # Future implementation
```

### Environment Progression

1. **Development:** Single node, Basic SKUs, public endpoints
2. **Staging:** 2 nodes, General Purpose, private endpoints
3. **Production:** 3+ nodes, Business Critical, full security

## Security Requirements

### Identity and Access Management

#### Managed Identities

```hcl
# AKS uses system-assigned managed identity
identity {
  type = "SystemAssigned"
}

# For Key Vault access
identity {
  type         = "UserAssigned"
  identity_ids = [azurerm_user_assigned_identity.aks.id]
}
```

#### RBAC Configuration

```hcl
# Azure AD integration
azure_active_directory_role_based_access_control {
  managed                = true
  admin_group_object_ids = [var.aks_admin_group_object_id]
}
```

### Network Security

#### Network Security Groups

```hcl
# AKS subnet NSG rules
security_rule {
  name                       = "AllowHTTPS"
  priority                   = 1001
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}
```

## Cost Control Requirements

### Daily Budget Targets

| Environment | Target Cost/Day | Monthly Estimate |
|------------|----------------|------------------|
| Development | $2.50 | $75 |
| Staging | $3.00 | $90 |
| Production | $8.00 | $240 |

### Resource Sizing

#### Basic SKU Selections

- **ACR:** Basic (~$5/month) - sufficient for learning
- **AKS:** Standard_B2s nodes - minimal viable compute
- **Log Analytics:** 30-day retention - cost control

#### Auto-Shutdown

```bash
# Daily destroy script
#!/bin/bash
ENV=${1:-dev}
cd "terraform/environments/$ENV"
terraform destroy -auto-approve
```

## Validation Requirements

### Infrastructure Health Checks

```bash
# Terraform validation
terraform validate
terraform plan

# Azure resource verification
az resource list --resource-group dev-learn-rg --output table

# AKS cluster validation
kubectl get nodes
kubectl get pods --all-namespaces
```

### Container Registry Validation

```bash
# ACR connectivity
az acr login --name sharedlearnacr

# Image operations
docker pull sharedlearnacr.azurecr.io/api-service-1:dev-ready
kubectl run test-pod --image=sharedlearnacr.azurecr.io/api-service-1:dev-ready
```

### Cost Monitoring

```bash
# Daily cost check
az consumption usage list \
  --start-date $(date -d "1 day ago" '+%Y-%m-%d') \
  --end-date $(date '+%Y-%m-%d') \
  --output table
```

## Troubleshooting Setup

### Common Issues

#### Service Principal Permissions

**Error:** "AuthorizationFailed" during role assignment  
**Solution:** Grant Owner role to terraform service principal

#### AKS Authentication

**Error:** kubelogin authentication timeout  
**Solution:** Use `--admin` flag for cluster access

#### Terraform State Lock

**Error:** "lock already held"  
**Solution:** `terraform force-unlock <lock-id>`

### Debug Commands

```bash
# Check service principal permissions
az role assignment list --assignee b5422da7-4709-4cdd-9ca4-47ea063df820

# Verify AKS kubelet identity
az aks show -g dev-learn-rg -n dev-learn-aks \
  --query "identityProfile.kubeletidentity.objectId" -o tsv

# Test ACR access
az acr repository list --name sharedlearnacr
```

## Implementation Phases

### Phase 1: Foundation (Current)

- [x] Service principal setup with Owner role
- [x] Terraform backend configuration
- [x] Networking and AKS modules
- [ ] Shared ACR implementation
- [ ] AKS-ACR integration testing

### Phase 2: Application Integration

- [ ] Sample application containers
- [ ] Container promotion workflow
- [ ] PostgreSQL and Key Vault integration
- [ ] End-to-end deployment testing

### Phase 3: Multi-Environment

- [ ] Staging environment setup
- [ ] Production environment planning
- [ ] Environment promotion pipeline
- [ ] Complete automation

This setup provides the foundation for enterprise-grade Azure container operations while maintaining cost efficiency for learning purposes.