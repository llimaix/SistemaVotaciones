project        = "sistema-votaciones"
environment    = "prod"
aws_region     = "us-east-1"
cicd_role_arns = []
# domain_aliases      = ["votaciones.mi-dominio.com"]
# acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxx"
# cicd_role_arns      = ["arn:aws:iam::123456789012:role/azure-devops-deploy-role"]

# Lambda roles (se actualizan cuando se despliegan las funciones con Serverless Framework)
lambda_role_arns = []

# Base de datos independiente
# ⚠ En PROD estos valores deben llegar como variables secretas del pipeline,
#    NO deben estar en texto plano aquí.
db_host     = "PLACEHOLDER_DB_HOST"
db_port     = "5432"
db_name     = "votaciones"
db_username = "PLACEHOLDER_USER"
db_password = "PLACEHOLDER_CHANGE_ME"

# JWT secret (placeholder; rotarlo en Secrets Manager después del primer apply)
jwt_secret_value = "PLACEHOLDER_JWT_SECRET_CHANGE_ME"
