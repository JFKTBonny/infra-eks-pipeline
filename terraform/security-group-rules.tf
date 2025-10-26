# This defines cross-group communication (worker ↔ cluster).
# This is the only place where you use source_security_group_id.
# security-group-rules.tf

# Worker nodes → EKS API (443)
resource "aws_security_group_rule" "workers_to_cluster_api" {
  description              = "Allow worker nodes to reach EKS API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
}

# Cluster → Worker nodes (ephemeral ports)
resource "aws_security_group_rule" "cluster_to_workers_ephemeral" {
  description              = "Allow control plane to talk to worker nodes"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
}
