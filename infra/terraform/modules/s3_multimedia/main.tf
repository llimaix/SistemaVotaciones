# ============================================================
#  Módulo: s3_multimedia
#  Bucket S3 privado para almacenar archivos multimedia
#  (imágenes, videos, documentos, etc.).
#  Incluye versioning, cifrado y lifecycle rules.
# ============================================================

resource "aws_s3_bucket" "multimedia" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Module = "s3_multimedia"
  })
}

resource "aws_s3_bucket_public_access_block" "multimedia" {
  bucket = aws_s3_bucket.multimedia.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "multimedia" {
  bucket = aws_s3_bucket.multimedia.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "multimedia" {
  bucket = aws_s3_bucket.multimedia.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CORS para que el frontend pueda subir/leer archivos directamente
resource "aws_s3_bucket_cors_configuration" "multimedia" {
  bucket = aws_s3_bucket.multimedia.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Lifecycle: mover versiones antiguas a Glacier y eliminar marcadores de borrado
resource "aws_s3_bucket_lifecycle_configuration" "multimedia" {
  bucket = aws_s3_bucket.multimedia.id

  rule {
    id     = "transition-old-versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}
