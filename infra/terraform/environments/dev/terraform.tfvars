project        = "sistema-votaciones"
environment    = "dev"
aws_region     = "us-east-1"
cicd_role_arns = []
# Agrega el ARN del rol de CI cuando lo tengas:
# cicd_role_arns = ["arn:aws:iam::123456789012:role/azure-devops-deploy-role"]

# Lambda roles (se actualizan cuando se despliegan las funciones con Serverless Framework)
lambda_role_arns = []

# Base de datos independiente
# ⚠ En producción pasa estos valores vía variables de pipeline (no en el .tfvars)
db_host     = "PLACEHOLDER_DB_HOST"
db_port     = "5432"
db_name     = "votaciones_dev"
db_username = "PLACEHOLDER_USER"
db_password = "PLACEHOLDER_CHANGE_ME"

# JWT secret (placeholder; rotarlo en Secrets Manager después del primer apply)
jwt_secret_value = "PLACEHOLDER_JWT_SECRET_CHANGE_ME"
