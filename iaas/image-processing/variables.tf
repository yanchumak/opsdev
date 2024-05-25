variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "upload_image_s3_bucket_name" {
  description = "Upload image"
  default     = "input-image"
}

variable "text_detection_results_s3_bucket_name" {
  description = "Text detection results"
  default     = "text-detection-results"
}

variable "env" {
  description = "Environment"
  default     = "dev"
}

variable "tenant" {
  description = "Tenant"
  default     = "homesandbox"
}

variable "s3_module_version" {
  description = "The version of the terraform-aws-modules/s3-bucket/aws module to use"
  type        = string
  default     = "4.1.2"
}

variable "lambda_module_version" {
  description = "The version of the terraform-aws-modules/lambda/aws module to use"
  type        = string
  default     = "7.4.0"
}