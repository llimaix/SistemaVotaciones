project        = "sistema-votaciones"
environment    = "dev"
aws_region     = "us-east-1"
cicd_role_arns = []
# cicd_role_arns = ["arn:aws:iam::123456789012:role/azure-devops-deploy-role"]

# Lambda roles — se actualizan cuando Serverless Framework despliega las funciones
lambda_role_arns = []

# ──────────────────────────────────────────────────────────
#  Secrets Manager — secretos a crear (vacíos)
#
#  Para CREAR un secreto → agregar entrada + terraform apply
#  Para ELIMINAR un secreto → quitar entrada + terraform apply
#
#  Los VALORES se rellenan en la consola AWS o con:
#    aws secretsmanager put-secret-value \
#      --secret-id /sistema-votaciones/dev/db/credentials \
#      --secret-string '{"host":"...","port":"5432","user":"...","pass":"..."}'
# ──────────────────────────────────────────────────────────
secrets = {
  "db/credentials" = { description = "Credenciales de la base de datos (host, port, user, pass)" }
  "auth/jwt"       = { description = "Clave secreta para firma de tokens JWT" }
  "app/config"     = { description = "Configuración general de la aplicación" }
}
