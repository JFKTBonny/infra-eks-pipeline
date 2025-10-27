#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NS="argocd"
PORT=32000  # NodePort for local access

kubectl create namespace "$ARGOCD_NS" || true
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=stable"
kubectl apply -n "$ARGOCD_NS" -f "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/namespace-install.yaml"

# patch service to NodePort
kubectl -n "$ARGOCD_NS" patch svc argocd-server -p '{"spec":{"type":"NodePort"}}'

NODE_PORT=$(kubectl -n "$ARGOCD_NS" get svc argocd-server -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

ARGOCD_PASS=$(kubectl -n "$ARGOCD_NS" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

echo "✅ ArgoCD installed"
echo "URL: https://$NODE_IP:$NODE_PORT"
echo "Username: admin"
echo "Password: $ARGOCD_PASS"
