#!/usr/bin/env bash
set -euo pipefail

log() { echo "[TOOLS] $*"; }

# Install helpers
install_aws_cli() { 
    command -v aws >/dev/null 2>&1 && return
    echo "Installing AWS CLI..."
    tmp=$(mktemp -d)
    pushd "$tmp" >/dev/null
    curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    popd >/dev/null; rm -rf "$tmp"
}

install_terraform() { 
    command -v terraform >/dev/null 2>&1 && return
    echo "Installing Terraform..."
    tmpd=$(mktemp -d); pushd "$tmpd" >/dev/null
    VER=$(curl -s 'https://checkpoint-api.hashicorp.com/v1/check/terraform' | jq -r .current_version)
    curl -sS -O "https://releases.hashicorp.com/terraform/${VER}/terraform_${VER}_linux_amd64.zip"
    unzip terraform_${VER}_linux_amd64.zip
    sudo mv terraform /usr/local/bin
    chmod 0755 /usr/local/bin/terraform
    popd >/dev/null; rm -rf "$tmpd"
}

install_kubectl() {
    command -v kubectl >/dev/null 2>&1 && return
    echo "Installing kubectl..."
    STABLE=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -L -s "https://dl.k8s.io/release/${STABLE}/bin/linux/amd64/kubectl" -o kubectl
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
}

install_jq_git() {
    sudo apt-get update -y
    command -v jq >/dev/null 2>&1 || sudo apt-get install -y jq
    command -v git >/dev/null 2>&1 || sudo apt-get install -y git
}

install_aws_cli
install_terraform
install_kubectl
install_jq_git

echo "✅ All tools installed."

