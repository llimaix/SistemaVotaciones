# ============================================================
#  Módulos que componen la infraestructura del entorno DEV
# ============================================================

# ── 1. CloudFront (sin dominio custom en dev) ─────────────
#       Se crea primero para obtener el ARN y pasárselo al S3
module "cloudfront" {
  source = "../../modules/cloudfront"

  project     = var.project
  environment = var.environment
  price_class = "PriceClass_100"

  # Se conecta al S3 frontend (referencia cruzada resuelta por Terraform)
  s3_bucket_id                   = module.s3_frontend.bucket_id
  s3_bucket_regional_domain_name = module.s3_frontend.bucket_regional_domain_name

  # Sin dominio custom en dev; usar el dominio *.cloudfront.net
  domain_aliases      = []
  acm_certificate_arn = ""

  tags = local.common_tags
}

# ── 2. S3 Frontend ───────────────────────────────────────
module "s3_frontend" {
  source = "../../modules/s3_frontend"

  bucket_name                 = "${var.project}-${var.environment}-frontend"
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
  force_destroy               = true # En dev podemos destruirlo libremente

  tags = local.common_tags
}

# ── 3. S3 Multimedia ─────────────────────────────────────
module "s3_multimedia" {
  source = "../../modules/s3_multimedia"

  bucket_name   = "${var.project}-${var.environment}-multimedia"
  force_destroy = true

  cors_allowed_origins = ["https://${module.cloudfront.distribution_domain_name}"]

  tags = local.common_tags
}

# ── 4. S3 Serverless ─────────────────────────────────────
module "s3_serverless" {
  source = "../../modules/s3_serverless"

  bucket_name             = "${var.project}-${var.environment}-serverless-artifacts"
  force_destroy           = true
  artifact_retention_days = 14
  max_artifact_versions   = 3

  # ARN del rol de CI/CD de Azure DevOps (se crea externamente o se puede agregar como módulo)
  allowed_principal_arns = var.cicd_role_arns

  tags = local.common_tags
}

# ── 5. Secrets Manager ───────────────────────────────────
module "secrets_manager" {
  source = "../../modules/secrets_manager"

  project     = var.project
  environment = var.environment

  # recovery_window_days = 0 → eliminación inmediata en dev (sin ventana de 7 días)
  recovery_window_days     = 0
  kms_deletion_window_days = 7

  # Secretos a crear: agrega/quita entradas aquí y en terraform.tfvars
  # para controlar qué secretos existen. Los valores se rellenan en la
  # consola AWS o mediante CLI; Terraform solo crea el "contenedor".
  secrets = var.secrets

  # Roles Lambda: se rellenan cuando se desplieguen las funciones
  allowed_read_arns = var.lambda_role_arns

  tags = local.common_tags
}

# ── Locals ────────────────────────────────────────────────
locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
