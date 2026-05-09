variable "project" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
}

variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

variable "domain_aliases" {
  description = "Dominios personalizados para CloudFront (p.ej. ['votaciones.mi-dominio.com'])"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM (us-east-1) para el dominio personalizado"
  type        = string
  default     = ""
}

variable "cicd_role_arns" {
  description = "ARNs de roles IAM del CI/CD"
  type        = list(string)
  default     = []
}

variable "lambda_role_arns" {
  description = "ARNs de roles IAM de las Lambdas con permiso de lectura sobre Secrets Manager"
  type        = list(string)
  default     = []
}

# ── Base de datos ─────────────────────────────────────────
variable "db_host" {
  description = "Host del servidor de base de datos independiente"
  type        = string
  default     = "PLACEHOLDER_DB_HOST"
}

variable "db_port" {
  description = "Puerto de la base de datos"
  type        = string
  default     = "5432"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "votaciones"
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
  default     = "PLACEHOLDER_USER"
  sensitive   = true
}

variable "db_password" {
  description = "Contraseña de la base de datos (solo para el create inicial)"
  type        = string
  default     = "PLACEHOLDER_CHANGE_ME"
  sensitive   = true
}

# ── JWT ───────────────────────────────────────────────────
variable "jwt_secret_value" {
  description = "Valor inicial del JWT secret (solo para el create inicial)"
  type        = string
  default     = "PLACEHOLDER_JWT_SECRET_CHANGE_ME"
  sensitive   = true
}

