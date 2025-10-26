#!/usr/bin/env bash
set -euo pipefail

log() { echo "[TF] $*"; }

log "Initializing Terraform..."
cd eks && terraform init -input=false -no-color

log "Planning..."
terraform plan -out=tfplan -input=false -no-color || true

log "Applying Terraform..."
terraform apply -auto-approve -input=false -no-color

# Optionally output cluster_name (try common outputs)
CLUSTER_NAME=$(terraform output -json | jq -r 'to_entries[0].value.value' || true)
echo "✅ Terraform applied. Cluster name: $CLUSTER_NAME"
