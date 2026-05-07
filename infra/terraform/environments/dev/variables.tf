variable "project" {
  description = "Nombre del proyecto (usado como prefijo en los nombres de recursos)"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
}

variable "aws_region" {
  description = "Región AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "cicd_role_arns" {
  description = "ARNs de roles IAM del CI/CD que pueden acceder al bucket serverless"
  type        = list(string)
  default     = []
}
