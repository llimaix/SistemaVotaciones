set -euo pipefail

STATE_BUCKET="${TF_STATE_BUCKET:-sistema-votaciones-tf-state}"
LOCK_TABLE="${TF_LOCK_TABLE:-sistema-votaciones-tf-locks}"
REGION="${AWS_REGION:-us-east-1}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region) REGION="$2"; shift 2 ;;
    --bucket) STATE_BUCKET="$2"; shift 2 ;;
    --table)  LOCK_TABLE="$2"; shift 2 ;;
    *) echo "Argumento desconocido: $1" >&2; exit 1 ;;
  esac
done

if ! command -v aws &>/dev/null; then
  echo "ERROR: AWS CLI no encontrado." >&2
  exit 1
fi

if ! aws sts get-caller-identity &>/dev/null; then
  echo "ERROR: No se pudo autenticar con AWS. Verifica las credenciales." >&2
  exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Cuenta AWS: ${ACCOUNT_ID} | region: ${REGION}"

CREATED_BUCKET=false
CREATED_TABLE=false

cleanup_on_error() {
  echo "Bootstrap fallo."
  $CREATED_BUCKET && echo "  Bucket '${STATE_BUCKET}' fue creado en esta ejecucion."
  $CREATED_TABLE  && echo "  Tabla  '${LOCK_TABLE}' fue creada en esta ejecucion."
  echo "  Puedes volver a ejecutar el script (es idempotente)."
}
trap cleanup_on_error ERR

echo "Bucket de estado remoto: ${STATE_BUCKET}"
if aws s3api head-bucket --bucket "${STATE_BUCKET}" 2>/dev/null; then
  echo "  Bucket ya existe, se omite."
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
  echo "  Bucket creado."
fi

aws s3api put-bucket-versioning \
  --bucket "${STATE_BUCKET}" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "${STATE_BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"},
      "BucketKeyEnabled": true
    }]
  }'

aws s3api put-public-access-block \
  --bucket "${STATE_BUCKET}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Evita que el bucket del estado de Terraform sea eliminado accidentalmente.
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

echo "Tabla DynamoDB para locking: ${LOCK_TABLE}"
if aws dynamodb describe-table --table-name "${LOCK_TABLE}" --region "${REGION}" &>/dev/null; then
  echo "  Tabla ya existe, se omite."
else
  aws dynamodb create-table \
    --table-name "${LOCK_TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}" \
    --output text > /dev/null
  CREATED_TABLE=true
  echo "  Tabla creada."
fi

MAX_WAIT=60
ELAPSED=0
INTERVAL=5
while true; do
  TABLE_STATUS=$(aws dynamodb describe-table \
    --table-name "${LOCK_TABLE}" \
    --region "${REGION}" \
    --query "Table.TableStatus" \
    --output text 2>/dev/null || echo "UNKNOWN")

  [ "${TABLE_STATUS}" = "ACTIVE" ] && break

  if [ "${ELAPSED}" -ge "${MAX_WAIT}" ]; then
    echo "ERROR: Tiempo de espera agotado. Estado: ${TABLE_STATUS}" >&2
    exit 1
  fi

  sleep "${INTERVAL}"
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "Bootstrap completado."
echo "  Bucket  : s3://${STATE_BUCKET}"
echo "  DynamoDB: ${LOCK_TABLE}"

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
