output "cloudfront_domain" {
  description = "URL pública del CloudFront (frontend)"
  value       = "https://${module.cloudfront.distribution_domain_name}"
}

output "cloudfront_distribution_id" {
  description = "ID del CloudFront Distribution (usado para invalidaciones de caché)"
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

# ── Secrets Manager ───────────────────────────────────────
output "secrets_kms_key_arn" {
  description = "ARN de la KMS key de secretos"
  value       = module.secrets_manager.kms_key_arn
}

output "secret_db_credentials_arn" {
  description = "ARN del secreto de credenciales de BD"
  value       = module.secrets_manager.db_credentials_secret_arn
}

output "secret_jwt_arn" {
  description = "ARN del secreto JWT"
  value       = module.secrets_manager.jwt_secret_arn
}

output "secret_app_config_arn" {
  description = "ARN del secreto de configuración de la app"
  value       = module.secrets_manager.app_config_secret_arn
}
