#!/usr/bin/env bash
# ============================================================
#  bootstrap.sh
#  Crea el bucket S3 de estado remoto y la tabla DynamoDB
#  para el locking de Terraform.
#
#  Ejecutar UNA SOLA VEZ antes del primer `terraform init`.
#  Requiere: AWS CLI configurado con permisos suficientes.
#
#  Uso:
#    chmod +x infra/scripts/bootstrap.sh
#    ./infra/scripts/bootstrap.sh
# ============================================================

set -euo pipefail

STATE_BUCKET="sistema-votaciones-tf-state"
LOCK_TABLE="sistema-votaciones-tf-locks"
REGION="us-east-1"

echo "▶ Creando bucket de estado remoto: ${STATE_BUCKET}"
if aws s3api head-bucket --bucket "${STATE_BUCKET}" 2>/dev/null; then
  echo "  ✓ El bucket ya existe, se omite la creación."
else
  if [ "${REGION}" = "us-east-1" ]; then
    aws s3api create-bucket \
      --bucket "${STATE_BUCKET}" \
      --region "${REGION}"
  else
    aws s3api create-bucket \
      --bucket "${STATE_BUCKET}" \
      --region "${REGION}" \
      --create-bucket-configuration LocationConstraint="${REGION}"
  fi
  echo "  ✓ Bucket creado."
fi

echo "▶ Habilitando versionado en el bucket..."
aws s3api put-bucket-versioning \
  --bucket "${STATE_BUCKET}" \
  --versioning-configuration Status=Enabled
echo "  ✓ Versionado habilitado."

echo "▶ Habilitando cifrado en el bucket..."
aws s3api put-bucket-encryption \
  --bucket "${STATE_BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}
    }]
  }'
echo "  ✓ Cifrado habilitado."

echo "▶ Bloqueando acceso público al bucket..."
aws s3api put-public-access-block \
  --bucket "${STATE_BUCKET}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "  ✓ Acceso público bloqueado."

echo "▶ Creando tabla DynamoDB para locking: ${LOCK_TABLE}"
if aws dynamodb describe-table --table-name "${LOCK_TABLE}" --region "${REGION}" 2>/dev/null; then
  echo "  ✓ La tabla ya existe, se omite la creación."
else
  aws dynamodb create-table \
    --table-name "${LOCK_TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}"
  echo "  ✓ Tabla creada."
fi

echo ""
echo "✅ Bootstrap completado."
echo "   Bucket : s3://${STATE_BUCKET}"
echo "   DynamoDB: ${LOCK_TABLE} (región: ${REGION})"
echo ""
echo "   Siguiente paso:"
echo "   cd infra/terraform/environments/dev && terraform init"
