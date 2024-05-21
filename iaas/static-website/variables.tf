variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Bucket name"
  default     = "website"
}

variable "env" {
  description = "Environment"
  default     = "dev"
}

variable "tenant" {
  description = "Tenant"
  default     = "homesandbox"
}
