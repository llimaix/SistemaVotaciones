variable "bucket_name" {
  description = "Nombre único del bucket S3 para el frontend"
  type        = string
}

variable "force_destroy" {
  description = "Permite destruir el bucket aunque tenga objetos"
  type        = bool
  default     = false
}

variable "cloudfront_distribution_arn" {
  description = "ARN del CloudFront Distribution (para bucket policy OAC)"
  type        = string
}

variable "tags" {
  description = "Tags a aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}
