variable "project" {
  description = "Nombre del proyecto (usado como prefijo en los nombres de recursos)"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (dev, prod, etc.)"
  type        = string
}

variable "tags" {
  description = "Tags a aplicar a todos los recursos del módulo"
  type        = map(string)
  default     = {}
}

# ── KMS ──────────────────────────────────────────────────
variable "kms_deletion_window_days" {
  description = "Días de espera antes de eliminar la KMS key (7-30)"
  type        = number
  default     = 7
}

# ── Secrets Manager ───────────────────────────────────────
variable "recovery_window_days" {
  description = "Días de recuperación antes de eliminar un secreto de forma permanente (0 = forzar, 7-30 = ventana)"
  type        = number
  default     = 7
}

variable "allowed_read_arns" {
  description = "Lista de ARNs (roles Lambda, CI/CD) con permiso de lectura sobre los secretos"
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
  description = "Contraseña de la base de datos (se ignorará en applies posteriores)"
  type        = string
  default     = "PLACEHOLDER_CHANGE_ME"
  sensitive   = true
}

# ── JWT ───────────────────────────────────────────────────
variable "jwt_secret_value" {
  description = "Valor inicial de la clave secreta JWT (se ignorará en applies posteriores)"
  type        = string
  default     = "PLACEHOLDER_JWT_SECRET_CHANGE_ME"
  sensitive   = true
}

# ── Configuración app (referencia a otros módulos) ────────
variable "s3_multimedia_bucket" {
  description = "Nombre del bucket S3 de multimedia (para app/config secret)"
  type        = string
  default     = ""
}

variable "cloudfront_domain" {
  description = "Dominio CloudFront del frontend (para app/config secret)"
  type        = string
  default     = ""
}
