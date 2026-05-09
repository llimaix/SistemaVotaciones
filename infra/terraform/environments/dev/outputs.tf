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
  description = "ARN de la KMS key de Secrets Manager"
  value       = module.secrets_manager.kms_key_arn
}

output "secret_arns" {
  description = "Mapa de ARNs de los secretos creados. Clave = sufijo de ruta (ej: 'db/credentials')"
  value       = module.secrets_manager.secret_arns
}

output "secret_names" {
  description = "Mapa de nombres completos de los secretos en AWS"
  value       = module.secrets_manager.secret_names
}
