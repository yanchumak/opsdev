terraform {
  backend "remote" {
    organization = "home-sandbox"

    workspaces {
      name = "opsdev"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region     = var.region
}

resource "aws_s3_bucket" "static_website" {
  bucket = ""
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name        = "Static Website"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.static_website.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.static_website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "deploy_user" {
  name = "deploy-user"
}

resource "aws_iam_access_key" "deploy_user" {
  user = aws_iam_user.deploy_user.name
}

resource "aws_iam_policy" "s3_policy" {
  name        = "s3-policy"
  description = "A policy to allow access to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.static_website.arn,
          "${aws_s3_bucket.static_website.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.deploy_user.name
  policy_arn = aws_iam_policy.s3_policy.arn
}
