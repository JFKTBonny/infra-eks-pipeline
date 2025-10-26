pipeline {
    agent any
    environment {
        CONFIG_FILE = 'deploy_config.yaml'
        WORKDIR = "eks-deploy-${env.BUILD_ID}"
    }
    options {
        timestamps()  // adds timestamps to console log
        ansiColor('xterm') // optional: colorizes log
    }
    stages {

        stage('Checkout Scripts & Config') {
            steps {
                script {
                    // Checkout the repo that contains modular scripts & deploy_config.yaml
                    checkout scm
                    echo "Checked out repo with deployment scripts."
                }
            }
        }

        stage('Prepare Environment') {
            steps {
                script {
                    echo "Installing prerequisites..."
                    sh '''
                    #!/bin/bash
                    set -euo pipefail
                    ./check_install_tools.sh
                    '''
                }
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                script {
                    sh """
                    #!/bin/bash
                    set -euo pipefail
                    ./clone_repo.sh \$(yq e '.git_repo_url' $CONFIG_FILE) \$(yq e '.terraform_subdir' $CONFIG_FILE)
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    dir("${WORKDIR}/repo/\$(yq e '.terraform_subdir' $CONFIG_FILE)") {
                        sh '''
                        #!/bin/bash
                        set -euo pipefail
                        ./terraform_apply.sh
                        '''
                    }
                }
            }
        }

        stage('Update kubeconfig') {
            steps {
                script {
                    dir("${WORKDIR}/repo/\$(yq e '.terraform_subdir' $CONFIG_FILE)") {
                        sh '''
                        #!/bin/bash
                        set -euo pipefail
                        CLUSTER_NAME=$(terraform output -json | jq -r 'to_entries[0].value.value' || true)
                        if [[ -z "$CLUSTER_NAME" ]]; then
                            echo "Cluster name not detected from Terraform outputs!"
                            exit 1
                        fi
                        ./update_kubeconfig.sh "$CLUSTER_NAME" \$(yq e '.aws_region' $CONFIG_FILE)
                        '''
                    }
                }
            }
        }

        stage('Install Argo CD') {
            steps {
                script {
                    sh '''
                    #!/bin/bash
                    set -euo pipefail
                    ./install_argocd.sh
                    NODEPORT=$(yq e '.argocd_nodeport' deploy_config.yaml)
                    kubectl -n argocd patch svc argocd-server -p '{"spec":{"type":"NodePort","ports":[{"port":443,"targetPort":443,"nodePort":'${NODEPORT}'}]}}'
                    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
                    ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
                    echo "======================================="
                    echo "ArgoCD URL: https://${NODE_IP}:${NODEPORT}"
                    echo "Username: admin"
                    echo "Password: ${ARGOCD_PASS}"
                    echo "======================================="
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment pipeline completed successfully."
        }
        failure {
            echo "⚠️ Deployment pipeline failed. Please check logs for details."
        }
    }
}
