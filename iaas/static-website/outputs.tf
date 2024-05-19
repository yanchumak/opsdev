output "s3_bucket_id" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}