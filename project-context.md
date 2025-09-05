# Azure Enterprise Learning Project Context

## Project Overview

- **Goal:** Learn enterprise Azure patterns with practical modularity decisions
- **Timeline:** 15 days with $200 Azure credit
- **Budget Target:** Under $100 total spend
- **Strategy:** Modules only for high-reuse components (networking, AKS), inline for simple resources (ACR, Key Vault, PostgreSQL)
- **Container Strategy:** Single shared ACR with environment tag promotion (dev-ready → staging-ready → prod-ready)

## Architecture Strategy

- **Modules:** Only for high-reuse, complex components (networking, AKS)
- **Inline:** Simpler resources with low reuse (ACR, Key Vault, PostgreSQL)
- **Environments:** dev → staging → prod progression with varying HA needs
- **Container Registry:** Shared Basic ACR with immutable image promotion workflow

## Container Image Strategy

**Registry Pattern:** Single shared ACR with environment tag promotion

```text
sharedlearnacr.azurecr.io/
├── api-service-1/
│   ├── v1.2.3-commit-abc123    # Original build
│   ├── dev-ready               # Promoted to dev
│   ├── staging-ready          # Promoted to staging
│   └── prod-ready             # Promoted to prod
├── api-service-2/ (same pattern)
└── web-app/ (same pattern)
```

**Promotion Workflow:**

1. **Build:** Code → Build → Push with commit SHA tag
2. **Dev Promotion:** Auto-tag as `dev-ready`, deploy to dev
3. **Staging Promotion:** Manual approval → tag as `staging-ready`, deploy to staging
4. **Prod Promotion:** Manual approval → tag as `prod-ready`, deploy to prod

**Benefits:**

- ✅ True immutability (same binary across environments)
- ✅ Clear audit trail (can trace prod image to exact commit)
- ✅ Easy rollbacks (re-tag previous version)
- ✅ Cost effective (single Basic ACR ~$5/month)

## Architecture Components

- **Compute:** AKS clusters with configurable HA (1-3 nodes depending on environment)
- **Database:** PostgreSQL Flexible Server (inline Terraform)
- **Registry:** Azure Container Registry Basic SKU (inline, shared across environments)
- **Security:** Key Vault for secrets (inline Terraform)
- **Networking:** VNet with subnets (reusable module - used 3+ times)

## Applications

1. **API Service 1:** Simple REST API with health endpoints
2. **API Service 2:** Database-connected REST API
3. **Web App:** Single page application frontend

## Terraform Service Principal Requirements

**Critical Configuration:** The terraform service principal needs temporary `Owner` role for learning:

```bash
# Grant temporary Owner role (learning environment)
az role assignment create \
  --assignee b5422da7-4709-4cdd-9ca4-47ea063df820 \
  --role Owner \
  --scope /subscriptions/7a5bee06-2155-4808-885b-ba1c53c04dbd

# Revert after learning project
az role assignment delete \
  --assignee b5422da7-4709-4cdd-9ca4-47ea063df820 \
  --role Owner \
  --scope /subscriptions/7a5bee06-2155-4808-885b-ba1c53c04dbd
```

**Why needed:** AKS-ACR integration requires role assignments (`AcrPull` permissions), which need `User Access Administrator` or `Owner` role.

## Development Standards

- **Terraform:** Module only when justified by reuse and complexity
- **Container Images:** Build once, promote with tags (no environment-specific builds)
- **Kubernetes:** Health checks, resource limits, security contexts
- **Docker:** Multi-stage builds, non-root users
- **Security:** Key Vault integration, private networking
- **Cost Control:** Daily destroy/rebuild pattern

## Learning Objectives

- Understand when modularity adds value vs. complexity
- Design reusable infrastructure components
- Implement enterprise networking patterns
- Master container promotion workflows instead of environment-specific builds
- Practice environment progression (dev → staging → prod)
- Apply cost optimization strategies

## Current Phase

Phase 1: Foundation setup - ACR integration with environment tag promotion

## Daily Budget

- Target: $3/day maximum
- Phase 1: ~$2/day (AKS + Basic ACR)
- Monitor with: az consumption usage list

## Architecture Evolution

```text
Phase 1: Dev environment with shared ACR
Phase 2: Database integration (PostgreSQL + Key Vault)
Phase 3: Complete dev stack with monitoring
Phase 4: Multi-environment promotion pipeline
Phase 5: Enterprise features (App Gateway, advanced security)
```

## Questions for Learning

- When should I create a module vs. keep resources inline?
- How do I design module interfaces (inputs/outputs) for reusability?
- What networking patterns work best for multi-environment AKS?
- How does container tag promotion work in practice vs. environment-specific registries?
- What are the security implications of shared vs. separate ACRs?