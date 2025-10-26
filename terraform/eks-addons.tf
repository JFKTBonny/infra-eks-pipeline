# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name = aws_eks_cluster.eks_cluster.name
#   addon_name   = "vpc-cni"
  
#   resolve_conflicts_on_update = "PRESERVE"

# }

# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name = aws_eks_cluster.eks_cluster.name
#   addon_name   = "kube-proxy"
  
#   resolve_conflicts_on_update = "PRESERVE"

# }

# resource "aws_eks_addon" "coredns" {
#   cluster_name = aws_eks_cluster.eks_cluster.name
#   addon_name   = "coredns"
  
#   resolve_conflicts_on_update = "PRESERVE"
  
# }

