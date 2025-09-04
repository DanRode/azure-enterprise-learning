# Azure Enterprise Learning Project Context

## Project Overview
- **Goal:** Learn enterprise Azure patterns with practical modularity decisions
- **Timeline:** 15 days with $200 Azure credit
- **Budget Target:** Under $100 total spend
- **Approach:** Daily destroy/rebuild for cost control
- **Learning Focus:** When to modularize vs. keep resources inline

## Architecture Strategy
- **Modules:** Only for high-reuse, complex components (networking, AKS)
- **Inline:** Simpler resources with low reuse (ACR, Key Vault, PostgreSQL)
- **Environments:** dev → staging → prod progression with varying HA needs

## Architecture Components
- **Compute:** AKS clusters with configurable HA (1-3 nodes depending on environment)
- **Database:** PostgreSQL Flexible Server (inline Terraform)
- **Registry:** Azure Container Registry (inline, shared across environments)
- **Security:** Key Vault for secrets (inline Terraform)
- **Networking:** VNet with subnets (reusable module - used 3+ times)

## Applications
1. **API Service 1:** Simple REST API with health endpoints
2. **API Service 2:** Database-connected REST API 
3. **Web App:** Single page application frontend

## Development Standards
- **Terraform:** Module only when justified by reuse and complexity
- **Kubernetes:** Health checks, resource limits, security contexts
- **Docker:** Multi-stage builds, non-root users
- **Security:** Key Vault integration, private networking
- **Cost Control:** Daily destroy/rebuild pattern

## Learning Objectives
- Understand when modularity adds value vs. complexity
- Design reusable infrastructure components
- Implement enterprise networking patterns
- Practice environment progression (dev → staging → prod)

## Current Phase
Phase 1: Foundation setup - focusing on networking and AKS module design

## Daily Budget
- Target: $3/day maximum
- Phase 1: ~$2/day (AKS + ACR)
- Monitor with: az consumption usage list

## Questions for Learning
- When should I create a module vs. keep resources inline?
- How do I design module interfaces (inputs/outputs) for reusability?
- What networking patterns work best for multi-environment AKS?