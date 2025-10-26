resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "prod-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.public[*].id
  instance_types  = ["t3.medium"]

  remote_access {
    ec2_ssh_key               = "jenkins-key"
    source_security_group_ids = [aws_security_group.worker_sg.id]
  }

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  tags = {
    Name = "prod-node-group"
  }
}
