#!/bin/bash

# Enterprise Pattern: ContainerInsights Cleanup Script
# This script handles the common issue where ContainerInsights prevents clean resource group deletion

set -e

ENVIRONMENT=${1:-"dev"}
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "🧹 Enterprise ContainerInsights Cleanup for $ENVIRONMENT environment"
echo "Subscription: $SUBSCRIPTION_ID"

# Function to clean ContainerInsights solution
cleanup_container_insights() {
    local rg_name=$1
    local workspace_name=$2
    
    echo "🔍 Checking for ContainerInsights solution in $rg_name..."
    
    # List all ContainerInsights solutions
    solutions=$(az monitor log-analytics solution list \
        --resource-group "$rg_name" \
        --query "[?contains(name, 'ContainerInsights')].name" \
        -o tsv 2>/dev/null || echo "")
    
    if [ -n "$solutions" ]; then
        echo "🗑️  Found ContainerInsights solutions. Removing..."
        for solution in $solutions; do
            echo "   Deleting solution: $solution"
            az monitor log-analytics solution delete \
                --resource-group "$rg_name" \
                --name "$solution" \
                --yes \
                --no-wait 2>/dev/null || echo "   Warning: Could not delete $solution"
        done
        
        echo "⏳ Waiting 30 seconds for solution cleanup..."
        sleep 30
    else
        echo "✅ No ContainerInsights solutions found"
    fi
}

# Function to force delete resource group
force_delete_rg() {
    local rg_name=$1
    
    echo "🗑️  Force deleting resource group: $rg_name"
    
    # First try normal delete
    if az group delete --name "$rg_name" --yes --no-wait 2>/dev/null; then
        echo "✅ Resource group deletion initiated successfully"
        
        # Wait and check status
        echo "⏳ Waiting for deletion to complete..."
        timeout=600  # 10 minutes
        elapsed=0
        
        while [ $elapsed -lt $timeout ]; do
            if ! az group exists --name "$rg_name" 2>/dev/null; then
                echo "✅ Resource group $rg_name successfully deleted"
                return 0
            fi
            
            sleep 10
            elapsed=$((elapsed + 10))
            echo "   Still deleting... (${elapsed}s elapsed)"
        done
        
        echo "⚠️  Deletion taking longer than expected"
    else
        echo "❌ Failed to delete resource group normally"
    fi
    
    return 1
}

# Main cleanup logic
case $ENVIRONMENT in
    "dev")
        RG_NAME="dev-learn-rg"
        WORKSPACE_NAME="dev-learn-aks-logs"
        ;;
    "staging")
        RG_NAME="staging-learn-rg"
        WORKSPACE_NAME="staging-learn-aks-logs"
        ;;
    "prod")
        RG_NAME="prod-learn-rg"
        WORKSPACE_NAME="prod-learn-aks-logs"
        ;;
    "shared")
        RG_NAME="shared-learn-rg"
        # No workspace for shared environment
        ;;
    *)
        echo "❌ Unknown environment: $ENVIRONMENT"
        echo "Usage: $0 [dev|staging|prod|shared]"
        exit 1
        ;;
esac

echo "🎯 Target Resource Group: $RG_NAME"

# Check if resource group exists
if ! az group exists --name "$RG_NAME" 2>/dev/null; then
    echo "✅ Resource group $RG_NAME does not exist"
    exit 0
fi

# Clean ContainerInsights if workspace exists
if [ -n "$WORKSPACE_NAME" ]; then
    cleanup_container_insights "$RG_NAME" "$WORKSPACE_NAME"
fi

# Force delete the resource group
force_delete_rg "$RG_NAME"

echo "🎉 Cleanup complete for $ENVIRONMENT environment"
