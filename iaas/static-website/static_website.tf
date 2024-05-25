provider "aws" {
  region = var.region
}

data "aws_iam_policy_document" "allow_access_from_internet_to_website" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.website_s3.arn,
      "${aws_s3_bucket.website_s3.arn}/*"
    ]
  }
}

resource "aws_s3_bucket" "website_s3" {
  bucket        = "${var.tenant}-${var.website_bucket_name}-${var.env}"
  force_destroy = true
  tags = {
    name = var.website_bucket_name
    tenant = var.tenant
    env = var.env
  }
}

resource "aws_s3_bucket_website_configuration" "website_s3_config" {
  bucket = aws_s3_bucket.website_s3.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_internet_to_website" {
  depends_on = [aws_s3_bucket_public_access_block.this, aws_s3_bucket_ownership_controls.this]
  bucket     = aws_s3_bucket.website_s3.id
  policy     = data.aws_iam_policy_document.allow_access_from_internet_to_website.json
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.website_s3.bucket
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.website_s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
