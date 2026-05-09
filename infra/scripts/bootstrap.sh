#!/usr/bin/env bash
# ============================================================
#  bootstrap.sh
#  Crea el bucket S3 de estado remoto y la tabla DynamoDB
#  para el locking de Terraform.
#
#  Ejecutar UNA SOLA VEZ antes del primer `terraform init`.
#  El script es idempotente: si los recursos ya existen, los
#  omite sin error.
#
#  Requiere: AWS CLI configurado con permisos suficientes.
#
#  Uso:
#    chmod +x infra/scripts/bootstrap.sh
#    ./infra/scripts/bootstrap.sh [--region us-east-1]
#
#  Variables de entorno opcionales:
#    TF_STATE_BUCKET   → sobreescribe el nombre del bucket
#    TF_LOCK_TABLE     → sobreescribe el nombre de la tabla
#    AWS_REGION        → sobreescribe la región
# ============================================================

set -euo pipefail

# ── Configuración ─────────────────────────────────────────
STATE_BUCKET="${TF_STATE_BUCKET:-sistema-votaciones-tf-state}"
LOCK_TABLE="${TF_LOCK_TABLE:-sistema-votaciones-tf-locks}"
REGION="${AWS_REGION:-us-east-1}"

# Parsear argumentos CLI
while [[ $# -gt 0 ]]; do
  case "$1" in
    --region) REGION="$2"; shift 2 ;;
    --bucket) STATE_BUCKET="$2"; shift 2 ;;
    --table)  LOCK_TABLE="$2"; shift 2 ;;
    *) echo "❌ Argumento desconocido: $1" >&2; exit 1 ;;
  esac
done

# ── Colores ───────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log_ok()   { echo -e "  ${GREEN}✓${NC} $*"; }
log_skip() { echo -e "  ${YELLOW}⊘${NC} $* (ya existe, se omite)"; }
log_err()  { echo -e "  ${RED}✗${NC} $*" >&2; }

# ── Validar prerequisitos ─────────────────────────────────
echo "▶ Validando prerequisitos..."

if ! command -v aws &>/dev/null; then
  log_err "AWS CLI no encontrado. Instálalo desde https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
  exit 1
fi

if ! aws sts get-caller-identity &>/dev/null; then
  log_err "No se pudo autenticar con AWS. Verifica tus credenciales (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY o perfil configurado)."
  exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
log_ok "Autenticado en cuenta AWS: ${ACCOUNT_ID} | región: ${REGION}"

# ── Trap: limpiar en caso de error parcial ────────────────
# Si el script falla a mitad, informa al usuario qué quedó creado
# para que pueda reejecutar o limpiar manualmente.
CREATED_BUCKET=false
CREATED_TABLE=false

cleanup_on_error() {
  echo ""
  log_err "Bootstrap falló de forma inesperada."
  if $CREATED_BUCKET; then
    echo "  ℹ Bucket '${STATE_BUCKET}' fue creado en esta ejecución."
  fi
  if $CREATED_TABLE; then
    echo "  ℹ Tabla DynamoDB '${LOCK_TABLE}' fue creada en esta ejecución."
  fi
  echo "  ➡ Puedes volver a ejecutar el script de forma segura (es idempotente)."
}
trap cleanup_on_error ERR

# ── 1. Crear bucket de estado remoto ─────────────────────
echo ""
echo "▶ Bucket de estado remoto: ${STATE_BUCKET}"
if aws s3api head-bucket --bucket "${STATE_BUCKET}" 2>/dev/null; then
  log_skip "Bucket"
else
  if [ "${REGION}" = "us-east-1" ]; then
    aws s3api create-bucket \
      --bucket "${STATE_BUCKET}" \
      --region "${REGION}" \
      --output text > /dev/null
  else
    aws s3api create-bucket \
      --bucket "${STATE_BUCKET}" \
      --region "${REGION}" \
      --create-bucket-configuration LocationConstraint="${REGION}" \
      --output text > /dev/null
  fi
  CREATED_BUCKET=true
  log_ok "Bucket creado"
fi

# ── 2. Versioning ─────────────────────────────────────────
echo "▶ Habilitando versioning..."
aws s3api put-bucket-versioning \
  --bucket "${STATE_BUCKET}" \
  --versioning-configuration Status=Enabled
log_ok "Versioning habilitado"

# ── 3. Cifrado ────────────────────────────────────────────
echo "▶ Habilitando cifrado AES256..."
aws s3api put-bucket-encryption \
  --bucket "${STATE_BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"},
      "BucketKeyEnabled": true
    }]
  }'
log_ok "Cifrado habilitado"

# ── 4. Bloquear acceso público ────────────────────────────
echo "▶ Bloqueando acceso público..."
aws s3api put-public-access-block \
  --bucket "${STATE_BUCKET}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
log_ok "Acceso público bloqueado"

# ── 5. Política anti-delete sobre el bucket de estado ─────
# Previene que el bucket (y el estado de Terraform) sea eliminado accidentalmente.
echo "▶ Aplicando política de protección anti-delete..."
BUCKET_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyBucketDelete",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:DeleteBucket",
      "Resource": "arn:aws:s3:::${STATE_BUCKET}"
    }
  ]
}
EOF
)
aws s3api put-bucket-policy \
  --bucket "${STATE_BUCKET}" \
  --policy "${BUCKET_POLICY}"
log_ok "Política anti-delete aplicada"

# ── 6. Crear tabla DynamoDB para locking ──────────────────
echo ""
echo "▶ Tabla DynamoDB para locking: ${LOCK_TABLE}"
if aws dynamodb describe-table --table-name "${LOCK_TABLE}" --region "${REGION}" &>/dev/null; then
  log_skip "Tabla"
else
  aws dynamodb create-table \
    --table-name "${LOCK_TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}" \
    --output text > /dev/null
  CREATED_TABLE=true
  log_ok "Tabla creada"
fi

# ── 7. Esperar a que la tabla DynamoDB esté ACTIVE ────────
echo "▶ Esperando que la tabla esté ACTIVE..."
MAX_WAIT=60   # segundos máximos de espera
ELAPSED=0
INTERVAL=5
while true; do
  TABLE_STATUS=$(aws dynamodb describe-table \
    --table-name "${LOCK_TABLE}" \
    --region "${REGION}" \
    --query "Table.TableStatus" \
    --output text 2>/dev/null || echo "UNKNOWN")

  if [ "${TABLE_STATUS}" = "ACTIVE" ]; then
    log_ok "Tabla ACTIVE"
    break
  fi

  if [ "${ELAPSED}" -ge "${MAX_WAIT}" ]; then
    log_err "Tiempo de espera agotado (${MAX_WAIT}s). Estado actual: ${TABLE_STATUS}"
    exit 1
  fi

  echo "  ⏳ Estado: ${TABLE_STATUS} — esperando ${INTERVAL}s más..."
  sleep "${INTERVAL}"
  ELAPSED=$((ELAPSED + INTERVAL))
done

# ── Resumen final ─────────────────────────────────────────
echo ""
echo -e "${GREEN}✅ Bootstrap completado exitosamente.${NC}"
echo "   Bucket  : s3://${STATE_BUCKET}  (cuenta: ${ACCOUNT_ID})"
echo "   DynamoDB: ${LOCK_TABLE}  (región: ${REGION})"
echo ""
echo "   Siguiente paso:"
echo "   cd infra/terraform/environments/dev && terraform init"
echo "   cd infra/terraform/environments/prod && terraform init"
