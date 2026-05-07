variable "project" {
  description = "Nombre del proyecto (usado en nombres de recursos)"
  type        = string
}

variable "environment" {
  description = "Entorno: dev, staging, prod"
  type        = string
}

variable "s3_bucket_id" {
  description = "ID (nombre) del bucket S3 frontend"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "Domain name regional del bucket S3 frontend"
  type        = string
}

variable "price_class" {
  description = "Clase de precio de CloudFront (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}

variable "domain_aliases" {
  description = "Lista de dominios personalizados (p.ej. ['app.mi-dominio.com']). Dejar vacío para usar el dominio de CloudFront."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM (us-east-1) para dominios personalizados"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags a aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}
