#!/bin/bash

# Daily destroy script with ContainerInsights handling
ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🗑️  Destroying $ENVIRONMENT environment to save costs..."

cd "$SCRIPT_DIR/../terraform/environments/$ENVIRONMENT"

# Show current resources
echo "📋 Current resources:"
terraform state list

read -p "Destroy the $ENVIRONMENT environment? (y/N): " confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "🔥 Destroying resources..."
    
    # First try normal terraform destroy
    if terraform destroy -auto-approve; then
        echo "✅ Environment destroyed successfully - saving ~$3/day"
    else
        echo "⚠️  Terraform destroy had issues, trying enterprise cleanup..."
        
        # Use our enterprise cleanup script for ContainerInsights issues
        "$SCRIPT_DIR/cleanup-container-insights.sh" "$ENVIRONMENT"
        
        # Clean up terraform state
        rm -f terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl
        rm -rf .terraform/
        
        echo "🧹 Cleanup complete - may need to re-initialize terraform"
    fi
else
    echo "❌ Destroy cancelled"
fi