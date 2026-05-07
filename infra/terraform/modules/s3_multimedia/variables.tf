variable "bucket_name" {
  description = "Nombre único del bucket S3 para multimedia"
  type        = string
}

variable "force_destroy" {
  description = "Permite destruir el bucket aunque tenga objetos"
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "Lista de orígenes permitidos para CORS (p.ej. ['https://app.mi-dominio.com'])"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags a aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}
