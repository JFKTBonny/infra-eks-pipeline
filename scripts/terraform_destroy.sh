#!/usr/bin/env bash
# terraform_destroy.sh
# Safely destroy infrastructure using Terraform

set -euo pipefail

# Optional: print each command for debug
set -x

# Change to Terraform configuration directory
cd terraform || { echo "Terraform directory 'terraform' not found"; exit 1; }

echo "Initializing Terraform with remote backend..."
terraform init \
  -backend-config="bucket=bonny-terraform-state-prod" \
  -backend-config="key=eks/terraform.tfstate" \
  -backend-config="region=${AWS_REGION:-us-east-1}" \
  -backend-config="encrypt=true" \
#   -backend-config="dynamodb_table=terraform-locks"

# Check if Terraform state exists
if terraform state list &>/dev/null; then
    echo "Terraform state exists. Destroying resources..."
    terraform destroy -auto-approve
    echo "Terraform destroy completed successfully."
else
    echo "No Terraform state found. Nothing to destroy."
fi
