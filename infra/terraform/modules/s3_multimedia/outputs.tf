output "bucket_id" {
  description = "ID (nombre) del bucket S3 multimedia"
  value       = aws_s3_bucket.multimedia.id
}

output "bucket_arn" {
  description = "ARN del bucket S3 multimedia"
  value       = aws_s3_bucket.multimedia.arn
}

output "bucket_regional_domain_name" {
  description = "Domain name regional del bucket multimedia"
  value       = aws_s3_bucket.multimedia.bucket_regional_domain_name
}
