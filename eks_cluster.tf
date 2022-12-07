resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = flatten([
      [for subnet in aws_subnet.private_subnet : subnet.id]
    ])
    security_group_ids      = [aws_security_group.control_plane_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }
  enabled_cluster_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment
  ]

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = "CREATE KEY"
    }
  }

  tags = {
    Name  = var.eks_cluster_name
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}

resource "aws_eks_addon" "example" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "vpc-cni"
  addon_version     = "v1.11.4-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
}

#https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html

resource "aws_iam_role" "eks_cluster" {
  name = "${var.eks_cluster_name}-cluster"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Principal = {
            Service = "eks.amazonaws.com"
          },
          Action = "sts:AssumeRole"
        }
      ]
    }
  )



  tags = {
    Name  = "${var.eks_cluster_name}-cluster"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
