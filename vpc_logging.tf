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

resource "aws_s3_bucket_logging" "log_bucket_logging" {
  bucket        = aws_s3_bucket.log_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "/log"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_enc_config" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_logging_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "s3_logging_key" {
  enable_key_rotation = true
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket                  = aws_s3_bucket.log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
