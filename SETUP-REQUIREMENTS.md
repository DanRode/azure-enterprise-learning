# Azure Enterprise Learning - Setup Requirements

## Prerequisites and Installation Guide

This document captures all tools, configurations, and setup steps required to replicate this Azure enterprise learning environment.

## Required Tool Installations

### 1. Azure CLI
**Status:** ✅ Pre-installed  
**Version:** Latest  
**Purpose:** Azure resource management and authentication  

```bash
# Installation (if needed)
brew install azure-cli

# Verification
az --version
az account show
```

### 2. Terraform
**Status:** ✅ Pre-installed  
**Version:** Latest  
**Purpose:** Infrastructure as Code management  

```bash
# Installation (if needed)
brew install terraform

# Verification
terraform --version
```

### 3. kubectl
**Status:** ✅ Pre-installed  
**Version:** Latest  
**Purpose:** Kubernetes cluster management  

```bash
# Installation (if needed)
brew install kubectl

# Verification
kubectl version --client
```

### 4. kubelogin (CRITICAL - Missing Initially)
**Status:** ❌ Missing, caused authentication failures  
**Version:** Latest  
**Purpose:** Azure AD authentication for AKS clusters  
**Issue:** AKS with Azure AD integration requires kubelogin for kubectl access

```bash
# Installation (REQUIRED)
brew install Azure/kubelogin/kubelogin

# Verification
kubelogin --version

# This was the error when missing:
# "kubelogin is not installed which is required to connect to AAD enabled cluster"
```

### 5. Git
**Status:** ✅ Pre-installed  
**Purpose:** Version control and repository management  

## Azure Account Requirements

### 1. Azure Subscription
**Requirement:** Active Azure subscription with sufficient credits  
**Used:** Personal subscription with $200 credit  
**Estimated Cost:** ~$2-3/day for dev environment  

### 2. Azure Authentication
**Method:** Azure CLI login  
**Setup:**
```bash
az login
az account set --subscription "<subscription-id>"
```

### 3. Terraform Backend Storage
**Requirement:** Azure Storage Account for Terraform state  
**Configuration:**
- Resource Group: `tfstate-rg`
- Storage Account: `tfstatec18b586c`
- Container: `tfstate`
- State Files: Environment-specific (e.g., `dev/terraform.tfstate`)

## Repository Setup

### 1. .gitignore Configuration
**Status:** ❌ Missing initially, caused large file commit errors  
**Issue:** Terraform provider binaries (260MB+) were committed to git  
**Solution:** Created comprehensive .gitignore

```bash
# The error that occurred:
# "terraform-provider-azurerm_v3.117.1_x5 is 260.76 MB; 
#  this exceeds GitHub's file size limit of 100.00 MB"
```

**Critical exclusions added:**
```gitignore
# Terraform files and directories
**/.terraform/
**/.terraform.lock.hcl
*.tfstate
*.tfstate.*
*.tfplan
*.tfplan.*
*.out

# Azure CLI and credentials
azure-sp.json
.azure/

# IDE and OS files
.vscode/settings.json
.DS_Store
```

### 2. Directory Structure
**Created Structure:**
```
azure-enterprise-learning/
├── .gitignore                    # CRITICAL - was missing
├── terraform/
│   ├── backend.tf               # Shared backend config
│   ├── modules/                 # Reusable modules
│   │   ├── networking/
│   │   └── aks/
│   └── environments/            # Environment-specific configs
│       └── dev/
├── k8s/                        # Kubernetes manifests
├── scripts/                    # Automation scripts
└── apps/                       # Application source code
```

## Development Environment Setup

### 1. VS Code Extensions (Recommended)
```json
{
  "recommendations": [
    "hashicorp.terraform",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "ms-vscode.azure-account",
    "ms-azuretools.vscode-azureterraform"
  ]
}
```

### 2. Shell Configuration
**Requirement:** Terraform and kubectl in PATH  
**Verification:**
```bash
which terraform
which kubectl
which az
which kubelogin  # This was missing!
```

## Network and Security Setup

### 1. Azure Resource Providers
**Status:** ✅ Automatically registered  
**Required providers:**
- Microsoft.ContainerService (AKS)
- Microsoft.Network (VNet, NSGs)
- Microsoft.OperationalInsights (Log Analytics)

### 2. Local Network Requirements
**Requirement:** Outbound HTTPS access for:
- Azure API endpoints
- Terraform provider downloads
- Container image pulls
- kubectl API access

## Troubleshooting - Issues Encountered

### Issue 1: kubelogin Missing
**Problem:** kubectl commands failed with Azure AD authentication error  
**Error Message:**
```
kubelogin is not installed which is required to connect to AAD enabled cluster.
```
**Solution:** `brew install Azure/kubelogin/kubelogin`

### Issue 2: Git Large File Error
**Problem:** Terraform .terraform/ directory committed to git  
**Error Message:**
```
terraform-provider-azurerm_v3.117.1_x5 is 260.76 MB; 
this exceeds GitHub's file size limit of 100.00 MB
```
**Solution:** 
1. Created .gitignore with Terraform exclusions
2. Removed files from git: `git rm -r --cached terraform/environments/dev/.terraform/`

### Issue 3: Azure AD Permissions
**Problem:** User account lacked cluster admin permissions  
**Error:** `User "uuid" cannot list resource "nodes"`  
**Solution:** Used admin credentials: `az aks get-credentials --admin`

### Issue 4: Terraform Module Not Found
**Problem:** Added new module but didn't reinitialize  
**Error:** `Module not installed. Run "terraform init"`  
**Solution:** `terraform init` after adding new modules

## Environment Variables (Optional)

```bash
# Terraform backend configuration (if using variables)
export ARM_RESOURCE_GROUP_NAME="tfstate-rg"
export ARM_STORAGE_ACCOUNT_NAME="tfstatec18b586c"
export ARM_CONTAINER_NAME="tfstate"

# Azure authentication (alternative to az login)
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

## Quick Setup Checklist

Before starting the project:

- [ ] Azure CLI installed and logged in (`az login`)
- [ ] Terraform installed and verified
- [ ] kubectl installed and verified  
- [ ] **kubelogin installed** (CRITICAL)
- [ ] Git repository initialized
- [ ] **.gitignore created** (prevents large file commits)
- [ ] Azure subscription with sufficient credits
- [ ] Terraform backend storage configured
- [ ] VS Code with recommended extensions (optional)

## Verification Commands

Run these to verify your setup:

```bash
# Tool versions
az --version
terraform --version  
kubectl version --client
kubelogin --version

# Azure connectivity
az account show
az account list-locations --output table

# Terraform backend access
terraform init  # Should succeed without errors

# Git setup
git status      # Should not show .terraform/ files
```

This setup ensures a clean, reproducible development environment for Azure enterprise learning projects.