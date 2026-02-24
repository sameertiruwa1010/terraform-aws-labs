# ============================================
# Terraform & Provider
# ============================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# ============================================
# 1. FREE Access Analyzer (Account Level)
# ============================================

resource "aws_accessanalyzer_analyzer" "sameer_analyzer" {
  analyzer_name = "sameer-analyzer"
  type          = "ACCOUNT"   # FREE

  tags = {
    Environment = "learning"
    Owner       = "sameer"
  }
}

# ============================================
# 2. Simple Free S3 Bucket
# ============================================

resource "aws_s3_bucket" "sameer_bucket" {
  bucket = "sameer-terraform-test-bucket"

  tags = {
    Environment = "learning"
    Owner       = "sameer"
  }
}

# Disable public block (required if testing public)
resource "aws_s3_bucket_public_access_block" "sameer_bucket_block" {
  bucket = aws_s3_bucket.sameer_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public read policy (safe for testing only)
data "aws_iam_policy_document" "public_read" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.sameer_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.sameer_bucket.id
  policy = data.aws_iam_policy_document.public_read.json

  depends_on = [
    aws_s3_bucket_public_access_block.sameer_bucket_block
  ]
}

# ============================================
# Outputs (Simple & Clean)
# ============================================

output "analyzer_name" {
  value = aws_accessanalyzer_analyzer.sameer_analyzer.analyzer_name
}

output "bucket_name" {
  value = aws_s3_bucket.sameer_bucket.bucket
}
