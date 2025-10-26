#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:?Provide EKS cluster name}"
AWS_REGION="${2:-us-east-1}"

aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
echo "✅ kubeconfig updated for cluster: $CLUSTER_NAME"
kubectl config current-context
