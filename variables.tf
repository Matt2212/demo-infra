variable "region" {
  description = "The desired aws region into deply the infrastructure"
  type        = string
  default     = "eu-west-3"
}

variable "cidr_block" {
  description = "The ipv4 cidr for the vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_num" {
  description = "The deisred number of private subnets"
  type        = number
  default     = 2
}

variable "vpc_name" {
  description = "The name of the vpc"
  type        = string
  default     = "eks_lab_vpc"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster"
  type        = string
  default     = "eks-lab-cluster"
}
