#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NS="argocd"
PORT=32000  # NodePort for local access

# Create namespace (ignore error if exists)
kubectl create namespace "$ARGOCD_NS" || true

# Apply CRDs and ArgoCD manifests
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=stable"
kubectl apply -n "$ARGOCD_NS" -f "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/namespace-install.yaml"

# Patch the argocd-server service to NodePort
kubectl -n "$ARGOCD_NS" patch svc argocd-server -p '{"spec":{"type":"NodePort"}}'

# Wait for argocd-server deployment to be ready
echo "⏳ Waiting for argocd-server to be ready..."
kubectl -n "$ARGOCD_NS" rollout status deployment argocd-server

# Wait until the initial admin secret exists
echo "⏳ Waiting for argocd-initial-admin-secret..."
until kubectl -n "$ARGOCD_NS" get secret argocd-initial-admin-secret >/dev/null 2>&1; do
  sleep 10
done

# Fetch NodePort and Node IP
NODE_PORT=$(kubectl -n "$ARGOCD_NS" get svc argocd-server -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Fetch ArgoCD initial admin password
ARGOCD_PASS=$(kubectl -n "$ARGOCD_NS" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

echo "✅ ArgoCD installed"
echo "URL: https://$NODE_IP:$NODE_PORT"
echo "Username: admin"
echo "Password: $ARGOCD_PASS"
