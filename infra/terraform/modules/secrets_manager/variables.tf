variable "project" {
  description = "Nombre del proyecto (prefijo en los nombres de recursos)"
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
  description = "Días de espera antes de eliminar la KMS key (7-30). En dev se puede usar 7."
  type        = number
  default     = 7
}

# ── Secrets Manager ───────────────────────────────────────
variable "recovery_window_days" {
  description = <<-EOT
    Días de recuperación antes de eliminar un secreto de forma permanente.
    0  = eliminar inmediatamente (útil en dev).
    7-30 = ventana de recuperación (recomendado en prod).
  EOT
  type        = number
  default     = 0
}

variable "secrets" {
  description = <<-EOT
    Mapa de secretos a crear. La clave es el sufijo de la ruta
    (el nombre final en AWS será /{project}/{environment}/{key}).
    Los secretos se crean VACÍOS; los valores se rellenan manualmente
    o por rotación automática fuera de Terraform.

    Para CREAR un secreto → agregar entrada al mapa + apply.
    Para ELIMINAR un secreto → quitar entrada del mapa + apply.

    Ejemplo:
      secrets = {
        "db/credentials" = { description = "Credenciales BD" }
        "auth/jwt"       = { description = "JWT secret" }
      }
  EOT
  type = map(object({
    description = string
  }))
  default = {}
}

variable "allowed_read_arns" {
  description = "ARNs de roles IAM (Lambdas, CI/CD) con permiso de lectura sobre los secretos"
  type        = list(string)
  default     = []
}

