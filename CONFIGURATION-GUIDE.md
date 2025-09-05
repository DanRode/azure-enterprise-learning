# Azure Enterprise Learning - Configuration Guide

## Step-by-Step Configuration and Troubleshooting

This document provides detailed configuration steps and troubleshooting guidance for common issues encountered during the Azure enterprise learning project setup.

## Phase 1: Initial Configuration

### Step 1: Repository Initialization

```bash
# Initialize git repository
git init
cd azure-enterprise-learning

# CRITICAL: Create .gitignore BEFORE any terraform commands
# This prevents committing large provider binaries
```

**⚠️ GOTCHA:** Without .gitignore, `terraform init` will create .terraform/ directory with 260MB+ files that exceed GitHub limits.

### Step 2: Terraform Backend Setup

**Pre-requisites:** Azure Storage Account for state management  

```bash
# Create backend configuration
cat > terraform/backend.tf << EOF
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
EOF
```

### Step 3: Module Development Workflow

**Order matters for dependencies:**

1. **Networking Module First** (foundation)
2. **AKS Module Second** (depends on networking)
3. **Environment Configuration** (consumes modules)

```bash
# Development sequence
terraform/modules/networking/     # Create first
terraform/modules/aks/           # Create second (uses networking outputs)
terraform/environments/dev/      # Create last (orchestrates modules)
```

## Terraform Configuration Patterns

### Module Interface Design

**Best Practice: Required variables for enterprise use**

```hcl
# modules/aks/variables.tf
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  # NO default = {} - make it required!
}
```

**Why:** Enterprise environments typically require tagging for cost allocation and governance.

### Environment-Specific State Files

**Configuration:**
```hcl
# environments/dev/main.tf
terraform {
  backend "azurerm" {
    key = "dev/terraform.tfstate"  # Environment-specific path
  }
}
```

**Benefits:**
- Isolated blast radius
- Independent environment lifecycles
- Team-based access control

### Module Dependency Management

**Pattern:**
```hcl
# Environment orchestrates module dependencies
module "networking" { ... }

module "aks" {
  subnet_id = module.networking.aks_subnet_id  # Clean dependency
}
```

## AKS-Specific Configuration

### Azure AD Integration Setup

**Configuration Applied:**
```hcl
# AKS cluster configuration
azure_active_directory_role_based_access_control_enabled = true
```

**Impact:** Requires kubelogin for kubectl access  
**Alternative:** Basic authentication (less secure)

### Network Configuration Decisions

**Service CIDR vs VNet CIDR:**
```hcl
# VNet addressing (for Azure resources)
vnet_address_space = "10.0.0.0/16"

# Service CIDR (internal Kubernetes services)
service_cidr = "10.1.0.0/16"
```

**Why separate?** Prevents IP conflicts as infrastructure scales.

### Cost Optimization Settings

```hcl
# Minimal viable configuration
default_node_pool {
  node_count     = 1           # No auto-scaling
  vm_size        = "Standard_B2s"  # Cheapest viable
  os_disk_size_gb = 30         # Minimal disk
}

# Monitoring with cost control  
oms_agent {
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

# Log retention limit
retention_in_days = 30
```

## Deployment Workflow

### Standard Deployment Sequence

```bash
# 1. Initialize (downloads providers, modules)
terraform init

# 2. Validate configuration
terraform validate

# 3. Plan (shows what will be created)
terraform plan

# 4. Apply (creates resources)
terraform apply

# 5. Verify (test connectivity)
kubectl get nodes
```

### Adding New Modules

```bash
# When adding modules to existing environment:
terraform init  # REQUIRED - downloads new module references
terraform plan  # Should show new resources
```

**⚠️ Common Error:** Forgetting `terraform init` after adding modules  
**Symptom:** "Module not installed" error

## Kubernetes Configuration

### Cluster Access Setup

**Method 1: Azure AD User (Requires Permissions)**
```bash
az aks get-credentials --resource-group dev-learn-rg --name dev-learn-aks
kubectl get nodes  # May fail with permissions error
```

**Method 2: Admin Access (Bypass Azure AD)**
```bash
az aks get-credentials --resource-group dev-learn-rg --name dev-learn-aks --admin
kubectl get nodes  # Should work
```

### Application Deployment Pattern

```yaml
# k8s/simple-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-app
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        resources:           # IMPORTANT: Resource limits
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: simple-app-service
spec:
  type: LoadBalancer      # Creates Azure Load Balancer
  ports:
  - port: 80
```

## Troubleshooting Guide

### Issue: kubelogin Authentication Failed

**Symptoms:**
```
To sign in, use a web browser to open the page https://microsoft.com/devicelogin 
and enter the code XYZ123 to authenticate.
Error: failed to authenticate: DeviceCodeCredential: context deadline exceeded
```

**Solutions:**
1. **Complete device login flow:** Follow the browser authentication
2. **Use admin credentials:** `az aks get-credentials --admin`
3. **Check Azure AD permissions:** Ensure user has cluster access

### Issue: Terraform State Lock

**Symptom:** "Error locking state: lock already held"  
**Cause:** Previous terraform command was interrupted  

**Solution:**
```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>

# Or wait for automatic timeout (typically 15 minutes)
```

### Issue: Azure Resource Provider Not Registered

**Symptom:** "The subscription is not registered to use namespace 'Microsoft.ContainerService'"

**Solution:**
```bash
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.OperationalInsights
```

### Issue: Load Balancer External IP Pending

**Symptom:** Service shows `<pending>` for EXTERNAL-IP  
**Causes:**
1. Azure Load Balancer provisioning (normal, wait 1-2 minutes)
2. Quota limits or subscription issues
3. Network security group blocking traffic

**Diagnosis:**
```bash
kubectl describe service simple-app-service
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Issue: Pod ImagePullBackOff

**Symptom:** Pod stuck in ImagePullBackOff state  
**Common Causes:**
1. Invalid image name/tag
2. Private registry authentication issues
3. Network connectivity problems

**Diagnosis:**
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

## Monitoring and Validation

### Health Check Commands

```bash
# Infrastructure validation
terraform show | grep "id ="        # List all created resources
az resource list --resource-group dev-learn-rg --output table

# AKS cluster health
kubectl get nodes -o wide
kubectl get pods --all-namespaces
kubectl top nodes  # Requires metrics-server

# Application validation
kubectl get deployments
kubectl get services
curl -I http://<external-ip>  # Test application access
```

### Cost Monitoring

```bash
# Azure cost analysis
az consumption usage list --output table
az monitor metrics list --resource <resource-id>

# Kubernetes resource usage
kubectl top pods
kubectl describe node <node-name>
```

## Cleanup Procedures

### Application Cleanup
```bash
kubectl delete -f k8s/simple-app.yaml
kubectl get services  # Verify LoadBalancer is gone
```

### Infrastructure Cleanup
```bash
# Plan destruction
terraform plan -destroy

# Execute destruction
terraform destroy -auto-approve

# Verify cleanup
az resource list --resource-group dev-learn-rg --output table
```

## Security Considerations

### Access Control
- ✅ Azure AD integration enabled
- ✅ RBAC enabled
- ✅ Managed identities used
- ✅ Admin credentials separate from user credentials

### Network Security  
- ✅ NSG rules limiting traffic
- ✅ Service endpoints for Azure services
- ⚠️ Public load balancer (acceptable for learning)
- ⚠️ Public AKS API endpoint (acceptable for learning)

### Secret Management
- ✅ No credentials in code
- ✅ Terraform state in Azure Storage
- ⚠️ kubeconfig contains cluster certificates (handle securely)

## Performance Optimization

### Terraform Performance
- Use targeted applies: `terraform apply -target=module.networking`
- Parallel resource creation (automatic)
- State file optimization with remote backend

### Kubernetes Performance  
- Resource limits prevent resource starvation
- Single replica sufficient for learning
- Load balancer provides high availability

This configuration guide provides the foundation for enterprise-grade Azure infrastructure with proper troubleshooting and operational procedures.