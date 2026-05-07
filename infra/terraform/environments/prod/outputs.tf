output "cloudfront_domain" {
  description = "URL pública del CloudFront (frontend)"
  value       = "https://${module.cloudfront.distribution_domain_name}"
}

output "cloudfront_distribution_id" {
  description = "ID del CloudFront Distribution"
  value       = module.cloudfront.distribution_id
}

output "s3_frontend_bucket" {
  description = "Nombre del bucket S3 del frontend"
  value       = module.s3_frontend.bucket_id
}

output "s3_multimedia_bucket" {
  description = "Nombre del bucket S3 de multimedia"
  value       = module.s3_multimedia.bucket_id
}

output "s3_serverless_bucket" {
  description = "Nombre del bucket S3 de artefactos serverless"
  value       = module.s3_serverless.bucket_id
}
