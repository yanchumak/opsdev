provider "aws" {
  region = var.region
}

module "upload_image_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  #version = var.s3_module_version

  bucket = "${var.tenant}-${var.upload_image_s3_bucket_name}-${var.env}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }

  tags = {
    Terraform   = "true"
    Environment = "${var.env}"
  }
}

module "text_detection_results_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  #version = var.s3_module_version

  bucket = "${var.tenant}-${var.text_detection_results_s3_bucket_name}-${var.env}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

data "archive_file" "dummy_function_zip" {
  type = "zip"
  source_file = "dummy_function.py"
  output_path = "dummy_function.zip"
}

module "rekognition_function" {
  source = "terraform-aws-modules/lambda/aws"
  #version = var.lambda_module_version

  function_name = "rekognition_function"
  description   = "My lambda function code is deployed separately"
  handler       = "rekognition_function.lambda_handler"
  runtime       = "python3.8"

  create_package          = false
  ignore_source_code_hash = true
  local_existing_package = data.archive_file.dummy_function_zip.output_path
}


resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.rekognition_function.lambda_function_name
  principal     = "s3.amazonaws.com"

  source_arn = module.upload_image_s3_bucket.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.upload_image_s3_bucket.s3_bucket_id

  lambda_function {
    lambda_function_arn = module.rekognition_function.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }
}
