output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.actions_web_bucket.bucket
}

output "website_endpoint" {
  description = "S3 static website endpoint"
  value       = aws_s3_bucket_website_configuration.actions_web_bucket.website_endpoint
}

output "website_url" {
  description = "Access URL"
  value       = "http://${aws_s3_bucket_website_configuration.actions_web_bucket.website_endpoint}"
}