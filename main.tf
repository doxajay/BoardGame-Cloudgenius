provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  id = "vpc-01c9148ac2c8d6a4e"  # Your existing VPC ID
}

data "aws_subnet" "subnet_1" {
  id = "subnet-06d35f2c522adab8f"  # Your first default subnet ID
}

data "aws_subnet" "subnet_2" {
  id = "subnet-09ccc23a13c2684b8"  # Your second default subnet ID
}

data "aws_subnet" "subnet_3" {
  id = "subnet-0a4121362cc47e646"  # Your third default subnet ID
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_eks_cluster" "my_cluster" {
  name     = "eksisaac-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      data.aws_subnet.subnet_1.id,
      data.aws_subnet.subnet_2.id,
      data.aws_subnet.subnet_3.id
    ]
  }
}

resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "isaacnodegroup"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
      data.aws_subnet.subnet_1.id,
      data.aws_subnet.subnet_2.id,
      data.aws_subnet.subnet_3.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}

# Optional: Outputs for easy reference
output "cluster_endpoint" {
  value = aws_eks_cluster.my_cluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.my_cluster.name
}
