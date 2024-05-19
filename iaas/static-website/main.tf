
provider "aws" {
    region     = var.region
}

resource "random_string" "random" {
  length = 6
  special = false
  upper = false
} 

resource "aws_s3_bucket" "bucket" {
  bucket = "website-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
