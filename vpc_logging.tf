resource "aws_flow_log" "s3_log" {
  log_destination      = aws_s3_bucket.log_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.eks_vpc.id

  tags = {
    Name  = "s3_log"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket_prefix = "demo_infra_log"

  tags = {
    Name  = "log_bucket"
    LAB   = "tesi_mattia"
    infra = "terraform"
  }
}
