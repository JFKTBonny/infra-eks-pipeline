# EKS Worker Node Security Group
resource "aws_security_group" "worker_sg" {
  name        = "eks-worker-sg"
  description = "EKS Worker Node Security Group"
  vpc_id      = aws_vpc.eks_vpc.id



  # Allow inbound traffic from other worker nodes (node-to-node)
  ingress {
    description = "Allow node-to-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow outbound communication to anywhere (internet / control plane)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-worker-sg"
  }
}
