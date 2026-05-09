# ============================================================
#  Módulos que componen la infraestructura del entorno PROD
# ============================================================

module "cloudfront" {
  source = "../../modules/cloudfront"

  project     = var.project
  environment = var.environment
  price_class = "PriceClass_100"

  s3_bucket_id                   = module.s3_frontend.bucket_id
  s3_bucket_regional_domain_name = module.s3_frontend.bucket_regional_domain_name

  # Dominio personalizado en prod (configurar variables)
  domain_aliases      = var.domain_aliases
  acm_certificate_arn = var.acm_certificate_arn

  tags = local.common_tags
}

module "s3_frontend" {
  source = "../../modules/s3_frontend"

  bucket_name                 = "${var.project}-${var.environment}-frontend"
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
  force_destroy               = false # En prod NO se destruye accidentalmente

  tags = local.common_tags
}

module "s3_multimedia" {
  source = "../../modules/s3_multimedia"

  bucket_name   = "${var.project}-${var.environment}-multimedia"
  force_destroy = false

  cors_allowed_origins = length(var.domain_aliases) > 0 ? [
    for d in var.domain_aliases : "https://${d}"
  ] : ["https://${module.cloudfront.distribution_domain_name}"]

  tags = local.common_tags
}

module "s3_serverless" {
  source = "../../modules/s3_serverless"

  bucket_name             = "${var.project}-${var.environment}-serverless-artifacts"
  force_destroy           = false
  artifact_retention_days = 30
  max_artifact_versions   = 5

  allowed_principal_arns = var.cicd_role_arns

  tags = local.common_tags
}

# ── 5. Secrets Manager ───────────────────────────────────
module "secrets_manager" {
  source = "../../modules/secrets_manager"

  project     = var.project
  environment = var.environment

  # Ventana de recuperación estándar en prod
  recovery_window_days     = 30
  kms_deletion_window_days = 30
  allowed_read_arns        = var.lambda_role_arns

  tags = local.common_tags
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
