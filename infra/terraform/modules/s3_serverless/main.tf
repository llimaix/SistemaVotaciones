# ============================================================
#  Módulo: s3_serverless
#  Bucket S3 privado para almacenar los artefactos de
#  despliegue de Serverless Framework (ZIPs de Lambdas,
#  CloudFormation templates, etc.).
# ============================================================

resource "aws_s3_bucket" "serverless" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Module = "s3_serverless"
  })
}

resource "aws_s3_bucket_public_access_block" "serverless" {
  bucket = aws_s3_bucket.serverless.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "serverless" {
  bucket = aws_s3_bucket.serverless.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "serverless" {
  bucket = aws_s3_bucket.serverless.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle: los artefactos viejos se limpian automáticamente
resource "aws_s3_bucket_lifecycle_configuration" "serverless" {
  bucket = aws_s3_bucket.serverless.id

  rule {
    id     = "cleanup-old-deployments"
    status = "Enabled"

    filter {
      prefix = ""
    }

    # Mantener solo las últimas N versiones de cada artefacto
    noncurrent_version_expiration {
      noncurrent_days           = var.artifact_retention_days
      newer_noncurrent_versions = var.max_artifact_versions
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}

# Política de bucket: permite a los roles de Lambda/CI acceder a los artefactos
data "aws_iam_policy_document" "serverless_access" {
  count = length(var.allowed_principal_arns) > 0 ? 1 : 0

  statement {
    sid    = "AllowServerlessDeployAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.allowed_principal_arns
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.serverless.arn,
      "${aws_s3_bucket.serverless.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "serverless" {
  count  = length(var.allowed_principal_arns) > 0 ? 1 : 0
  bucket = aws_s3_bucket.serverless.id
  policy = data.aws_iam_policy_document.serverless_access[0].json

  depends_on = [aws_s3_bucket_public_access_block.serverless]
}
