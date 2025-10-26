#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:?Provide Git repo URL}"
TF_SUBDIR="${2:-.}"
WORKDIR="${PWD}/eks-deploy-$(date +%s)"

mkdir -p "$WORKDIR"
git clone "$REPO_URL" "$WORKDIR/repo"
cd "$WORKDIR/repo/$TF_SUBDIR" || { echo "Terraform directory not found"; exit 1; }
echo "✅ Repo cloned to $WORKDIR"
