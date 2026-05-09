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

variable "lambda_role_arns" {
  description = "ARNs de roles IAM de las Lambdas con permiso de lectura sobre Secrets Manager"
  type        = list(string)
  default     = []
}

# ── Secrets Manager ───────────────────────────────────────
variable "secrets" {
  description = <<-EOT
    Mapa de secretos a crear en AWS Secrets Manager.
    La clave es el sufijo de ruta; el nombre final en AWS será
    /{project}/{environment}/{key}.

    Los secretos se crean VACÍOS. Para agregar un secreto:
      añadir entrada aquí + terraform apply.
    Para eliminar un secreto:
      quitar entrada aquí + terraform apply.
  EOT
  type = map(object({
    description = string
  }))
  default = {}
}
