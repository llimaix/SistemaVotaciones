# ============================================================
#  Módulo: cloudfront
#  CloudFront Distribution con Origin Access Control (OAC).
#  Sirve la SPA desde el S3 frontend de forma segura y rápida.
# ============================================================

# Origin Access Control (OAC) — reemplaza al deprecado OAI
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.project}-${var.environment}-oac"
  description                       = "OAC para acceder al S3 frontend de ${var.project}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project} - ${var.environment} frontend"
  default_root_object = "index.html"
  price_class         = var.price_class
  aliases             = var.domain_aliases

  # ── Origin: S3 Frontend ──────────────────────────────────
  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = "S3-${var.s3_bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  # ── Comportamiento por defecto ───────────────────────────
  default_cache_behavior {
    target_origin_id       = "S3-${var.s3_bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # ── SPA: redirigir 403/404 al index.html (React/Vue/Angular)
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  # ── Certificado SSL ──────────────────────────────────────
  dynamic "viewer_certificate" {
    for_each = length(var.domain_aliases) > 0 ? [1] : []
    content {
      acm_certificate_arn      = var.acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  dynamic "viewer_certificate" {
    for_each = length(var.domain_aliases) == 0 ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  # ── Restricciones geográficas ────────────────────────────
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(var.tags, {
    Module = "cloudfront"
  })
}
