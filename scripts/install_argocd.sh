#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NS="argocd"
LOCAL_PORT=8080  # Local port for port-forward

# Create namespace (ignore error if exists)
kubectl create namespace "$ARGOCD_NS" || true

# Apply CRDs and ArgoCD manifests
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=stable"
kubectl apply -n "$ARGOCD_NS" -f "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/namespace-install.yaml"

# Wait for argocd-server deployment to be ready
echo "⏳ Waiting for argocd-server to be ready..."
kubectl -n "$ARGOCD_NS" rollout status deployment argocd-server

# Wait until the initial admin secret exists
echo "⏳ Waiting for argocd-initial-admin-secret..."
until kubectl -n "$ARGOCD_NS" get secret argocd-initial-admin-secret >/dev/null 2>&1; do
  sleep 5
done

# Fetch ArgoCD initial admin password
ARGOCD_PASS=$(kubectl -n "$ARGOCD_NS" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

# Start port-forward in the background
echo "⏳ Starting port-forward from localhost:$LOCAL_PORT to argocd-server:443..."
kubectl -n "$ARGOCD_NS" port-forward svc/argocd-server "$LOCAL_PORT":443 >/dev/null 2>&1 &

PORT_FORWARD_PID=$!
trap "echo 'Stopping port-forward'; kill $PORT_FORWARD_PID" EXIT

echo "✅ ArgoCD installed and accessible via port-forward"
echo "URL: https://localhost:$LOCAL_PORT"
echo "Username: admin"
echo "Password: $ARGOCD_PASS"
echo ""
echo "Port-forward will remain active while this script is running."
echo "Press Ctrl+C to stop the port-forward when done."
wait $PORT_FORWARD_PID
