resource "aws_kms_key" "secrets" {
  description             = "KMS key para secretos de ${var.project}-${var.environment}"
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = true

  tags = merge(var.tags, { Module = "secrets_manager" })
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.project}-${var.environment}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# Cada entrada del mapa var.secrets genera un secreto vacio.
# Para crear un secreto -> agregar al mapa en tfvars.
# Para eliminarlo -> quitar del mapa + apply.
resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.secrets

  name                    = "/${var.project}/${var.environment}/${each.key}"
  description             = each.value.description
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = var.recovery_window_days

  tags = merge(var.tags, {
    Module     = "secrets_manager"
    SecretPath = each.key
  })
}

data "aws_iam_policy_document" "secrets_read" {
  count = length(var.allowed_read_arns) > 0 ? 1 : 0

  statement {
    sid    = "AllowReadSecrets"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.allowed_read_arns
    }

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = [for s in aws_secretsmanager_secret.secrets : s.arn]
  }

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.allowed_read_arns
    }

    actions = ["kms:Decrypt", "kms:DescribeKey"]

    resources = [aws_kms_key.secrets.arn]
  }
}

resource "aws_secretsmanager_secret_policy" "secrets" {
  for_each = length(var.allowed_read_arns) > 0 ? var.secrets : {}

  secret_arn = aws_secretsmanager_secret.secrets[each.key].arn
  policy     = data.aws_iam_policy_document.secrets_read[0].json
}
