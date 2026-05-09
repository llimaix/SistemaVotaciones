output "kms_key_arn" {
  description = "ARN de la KMS key usada para cifrar los secretos"
  value       = aws_kms_key.secrets.arn
}

output "kms_key_alias" {
  description = "Alias de la KMS key"
  value       = aws_kms_alias.secrets.name
}

output "db_credentials_secret_arn" {
  description = "ARN del secreto de credenciales de base de datos"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_credentials_secret_name" {
  description = "Nombre del secreto de credenciales de base de datos"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "jwt_secret_arn" {
  description = "ARN del secreto JWT"
  value       = aws_secretsmanager_secret.jwt_secret.arn
}

output "jwt_secret_name" {
  description = "Nombre del secreto JWT"
  value       = aws_secretsmanager_secret.jwt_secret.name
}

output "app_config_secret_arn" {
  description = "ARN del secreto de configuración general"
  value       = aws_secretsmanager_secret.app_config.arn
}

output "app_config_secret_name" {
  description = "Nombre del secreto de configuración general"
  value       = aws_secretsmanager_secret.app_config.name
}
