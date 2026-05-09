# ============================================================
#  Módulo: secrets_manager
#  Gestiona secretos de la aplicación en AWS Secrets Manager.
#  Todos los secretos se cifran con una clave KMS dedicada.
#
#  Secretos creados:
#    /{project}/{env}/db/credentials    → BD externa (host, puerto, usuario, pass)
#    /{project}/{env}/auth/jwt          → Clave secreta para firma de tokens JWT
#    /{project}/{env}/app/config        → Configuración general de la app
# ============================================================

# ── KMS Key dedicada para cifrar los secretos ─────────────
resource "aws_kms_key" "secrets" {
  description             = "KMS key para secretos de ${var.project}-${var.environment}"
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Module = "secrets_manager"
  })
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.project}-${var.environment}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# ── Secreto: credenciales de base de datos ────────────────
# La BD es un servidor independiente (no en AWS).
# El valor inicial es un placeholder; se actualiza fuera de Terraform.
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "/${var.project}/${var.environment}/db/credentials"
  description             = "Credenciales de la base de datos para ${var.project}-${var.environment}"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = var.recovery_window_days

  tags = merge(var.tags, {
    Module     = "secrets_manager"
    SecretType = "database"
  })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
    username = var.db_username
    password = var.db_password
  })

  # Ignorar cambios posteriores para que el pipeline/ops pueda rotar la contraseña
  # sin que Terraform la revierta en el siguiente apply.
  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ── Secreto: clave JWT ────────────────────────────────────
resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "/${var.project}/${var.environment}/auth/jwt"
  description             = "Clave de firma JWT para ${var.project}-${var.environment}"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = var.recovery_window_days

  tags = merge(var.tags, {
    Module     = "secrets_manager"
    SecretType = "auth"
  })
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id = aws_secretsmanager_secret.jwt_secret.id
  secret_string = jsonencode({
    jwt_secret       = var.jwt_secret_value
    jwt_expiry_hours = 24
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ── Secreto: configuración general de la app ──────────────
resource "aws_secretsmanager_secret" "app_config" {
  name                    = "/${var.project}/${var.environment}/app/config"
  description             = "Configuración general de ${var.project}-${var.environment}"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = var.recovery_window_days

  tags = merge(var.tags, {
    Module     = "secrets_manager"
    SecretType = "config"
  })
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id = aws_secretsmanager_secret.app_config.id
  secret_string = jsonencode({
    environment          = var.environment
    s3_multimedia_bucket = var.s3_multimedia_bucket
    cloudfront_domain    = var.cloudfront_domain
  })

  lifecycle {
    # Se actualiza automáticamente si cambian bucket/dominio
    ignore_changes = []
  }
}

# ── Política de recurso: acceso de lectura para Lambdas ───
# Solo se aplica si se proporcionan ARNs de roles permitidos.
data "aws_iam_policy_document" "secrets_read" {
  count = length(var.allowed_read_arns) > 0 ? 1 : 0

  statement {
    sid    = "AllowLambdaReadSecrets"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.allowed_read_arns
    }

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.allowed_read_arns
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [aws_kms_key.secrets.arn]
  }
}

resource "aws_secretsmanager_secret_policy" "db_credentials" {
  count      = length(var.allowed_read_arns) > 0 ? 1 : 0
  secret_arn = aws_secretsmanager_secret.db_credentials.arn
  policy     = data.aws_iam_policy_document.secrets_read[0].json
}

resource "aws_secretsmanager_secret_policy" "jwt_secret" {
  count      = length(var.allowed_read_arns) > 0 ? 1 : 0
  secret_arn = aws_secretsmanager_secret.jwt_secret.arn
  policy     = data.aws_iam_policy_document.secrets_read[0].json
}

resource "aws_secretsmanager_secret_policy" "app_config" {
  count      = length(var.allowed_read_arns) > 0 ? 1 : 0
  secret_arn = aws_secretsmanager_secret.app_config.arn
  policy     = data.aws_iam_policy_document.secrets_read[0].json
}
