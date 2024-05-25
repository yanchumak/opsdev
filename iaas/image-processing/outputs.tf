output "input_image_s3_bucket_id" {
  value = module.upload_image_s3_bucket.s3_bucket_id
}

output "text_detection_results_s3_bucket_id" {
  value = module.text_detection_results_s3_bucket.s3_bucket_id
}
