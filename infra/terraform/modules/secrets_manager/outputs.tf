output "kms_key_arn" {
  description = "ARN de la KMS key usada para cifrar los secretos"
  value       = aws_kms_key.secrets.arn
}

output "kms_key_alias" {
  description = "Alias de la KMS key"
  value       = aws_kms_alias.secrets.name
}

output "secret_arns" {
  description = <<-EOT
    Mapa de ARNs de los secretos creados.
    La clave es el sufijo de ruta definido en var.secrets.
    Ejemplo: secret_arns["db/credentials"] → arn:aws:secretsmanager:...
  EOT
  value = {
    for k, s in aws_secretsmanager_secret.secrets : k => s.arn
  }
}

output "secret_names" {
  description = "Mapa de nombres completos de los secretos en AWS (/{project}/{env}/{key})"
  value = {
    for k, s in aws_secretsmanager_secret.secrets : k => s.name
  }
}
