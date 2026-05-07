output "bucket_id" {
  description = "ID (nombre) del bucket S3 serverless"
  value       = aws_s3_bucket.serverless.id
}

output "bucket_arn" {
  description = "ARN del bucket S3 serverless"
  value       = aws_s3_bucket.serverless.arn
}

output "bucket_regional_domain_name" {
  description = "Domain name regional del bucket serverless"
  value       = aws_s3_bucket.serverless.bucket_regional_domain_name
}
