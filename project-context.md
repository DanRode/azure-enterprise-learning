# Azure Enterprise Learning Project Context

## Project Overview
- **Goal:** Learn enterprise Azure patterns with AKS, Terraform, and CI/CD
- **Timeline:** 15 days with $200 Azure credit
- **Budget Target:** Under $100 total spend
- **Approach:** Daily destroy/rebuild for cost control

## Architecture Components
- **Compute:** AKS clusters (dev + prod), single B2s nodes
- **Database:** PostgreSQL Flexible Server (B1ms burstable)
- **Registry:** Azure Container Registry (Basic tier, shared)
- **Security:** Key Vault for secrets, managed identities
- **Networking:** VNet with AKS and database subnets

## Applications
1. **API Service 1:** Simple REST API with health endpoints
2. **API Service 2:** Database-connected REST API 
3. **Web App:** Single page application frontend

## Development Standards
- **Terraform:** Modular structure, Azure naming conventions
- **Kubernetes:** Health checks, resource limits, security contexts
- **Docker:** Multi-stage builds, non-root users
- **Security:** Key Vault integration, private networking
- **Cost Control:** Daily destroy/rebuild pattern

## Current Phase
Phase 1: Foundation setup

## Daily Budget
- Target: $3/day maximum
- Phase 1: ~$2/day (AKS + ACR)
- Monitor with: az consumption usage list