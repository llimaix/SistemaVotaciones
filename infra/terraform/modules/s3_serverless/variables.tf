variable "bucket_name" {
  description = "Nombre único del bucket S3 para artefactos serverless"
  type        = string
}

variable "force_destroy" {
  description = "Permite destruir el bucket aunque tenga objetos"
  type        = bool
  default     = false
}

variable "artifact_retention_days" {
  description = "Días que se conservan versiones antiguas de artefactos antes de eliminarlas"
  type        = number
  default     = 30
}

variable "max_artifact_versions" {
  description = "Número máximo de versiones no-actuales a conservar por objeto"
  type        = number
  default     = 5
}

variable "allowed_principal_arns" {
  description = "Lista de ARNs de roles/usuarios IAM que pueden leer/escribir artefactos (p.ej. rol del CI). Dejar vacío para no crear bucket policy."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags a aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}
