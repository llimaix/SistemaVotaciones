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
