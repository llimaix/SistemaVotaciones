output "bucket_id" {
  description = "ID (nombre) del bucket S3 frontend"
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "ARN del bucket S3 frontend"
  value       = aws_s3_bucket.frontend.arn
}

output "bucket_regional_domain_name" {
  description = "Domain name regional del bucket (usado como origin en CloudFront)"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}
