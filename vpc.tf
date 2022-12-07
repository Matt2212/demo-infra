locals {
  avz = data.aws_availability_zones.available.names
}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                            = var.vpc_name
    LAB                                             = "tesi_mattia"
    infra                                           = "terraform"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Allow session manager connection

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.eu-west-3.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.data_plane_sg.id]
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  private_dns_enabled = true

  tags = {
    Name  = "ssm"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.eu-west-3.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.data_plane_sg.id]
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  private_dns_enabled = true

  tags = {
    Name  = "ssmmessages"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.eu-west-3.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.data_plane_sg.id]
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  private_dns_enabled = true

  tags = {
    Name  = "ec2messages"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}

# Allow eks to work properly

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.eu-west-3.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.data_plane_sg.id]
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  private_dns_enabled = true

  tags = {
    Name  = "ec2"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}
resource "aws_vpc_endpoint" "sts" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.eu-west-3.sts"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.data_plane_sg.id]
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  private_dns_enabled = true

  tags = {
    Name  = "sts"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.eu-west-3.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.data_plane_sg.id]
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  private_dns_enabled = true

  tags = {
    Name  = "ecr.api"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.eu-west-3.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.data_plane_sg.id]
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  private_dns_enabled = true

  tags = {
    Name  = "ecr.dkr"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.eks_vpc.id
  service_name = "com.amazonaws.eu-west-3.s3"

  route_table_ids = [aws_route_table.private_rt.id]
  tags = {
    Name  = "s3"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.eks_vpc.id
  count             = var.private_subnet_num
  cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone = local.avz[count.index % length(local.avz)]

  tags = {
    Name                                            = "${var.vpc_name}_subnet-${count.index}"
    LAB                                             = "tesi_mattia"
    infra                                           = "terraform"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name  = "${var.vpc_name}_private_rt"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}

resource "aws_route_table_association" "private_association" {
  count = length(aws_subnet.private_subnet)

  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}
