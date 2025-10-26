output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}


output "cluster_certificate" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "kubeconfig" {
  value = <<EOT
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks_cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks_cluster.certificate_authority[0].data}
  name: ${aws_eks_cluster.eks_cluster.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.eks_cluster.name}
    user: aws
  name: ${aws_eks_cluster.eks_cluster.name}
current-context: ${aws_eks_cluster.eks_cluster.name}
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${aws_eks_cluster.eks_cluster.name}"
EOT
}