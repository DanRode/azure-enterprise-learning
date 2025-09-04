#!/bin/bash

ENVIRONMENT=${1:-dev}

echo "Destroying $ENVIRONMENT environment to save costs..."

cd terraform/environments/$ENVIRONMENT

# Show current resources
echo "Current resources:"
terraform state list

read -p "Destroy the $ENVIRONMENT environment? (y/N): " confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    echo " Destroying resources..."
    terraform destroy -auto-approve
    echo "Environment destroyed - saving ~$3/day"
else
    echo "Destroy cancelled"
fi