#!/bin/bash

ENVIRONMENT=${1:-dev}

echo "️Rebuilding $ENVIRONMENT environment..."

cd terraform/environments/$ENVIRONMENT

echo "Applying infrastructure..."
terraform init
terraform plan
terraform apply -auto-approve

echo "Environment rebuilt successfully"