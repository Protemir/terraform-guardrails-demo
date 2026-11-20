# Общее окружение стенда для up.sh и тестов: source stand/env.sh
# Ключи MinIO берутся из окружения (секреты CI) или один раз генерируются в .stand.env (в .gitignore).

TF="${TF:-terraform}"
MC_IMAGE="${MC_IMAGE:-cgr.dev/chainguard/minio-client:latest}"

if [[ -z "${MINIO_ROOT_USER:-}" || -z "${MINIO_ROOT_PASSWORD:-}" ]]; then
  if [[ ! -f .stand.env ]]; then
    echo "MINIO_ROOT_USER=stand-$(openssl rand -hex 4)" > .stand.env
    echo "MINIO_ROOT_PASSWORD=$(openssl rand -hex 24)" >> .stand.env
  fi
  set -a; source .stand.env; set +a
fi
if [[ -n "${GITHUB_ACTIONS:-}" ]]; then echo "::add-mask::${MINIO_ROOT_PASSWORD}"; fi

# Клиент MinIO в контейнере, без установки: mc ls stand/backups
mc() { docker run --rm --network kind -e "MC_HOST_stand=http://${MINIO_ROOT_USER}:${MINIO_ROOT_PASSWORD}@minio:9000" "${MC_IMAGE}" "$@"; }

KIND_CIDR=$(docker network inspect kind -f '{{range .IPAM.Config}}{{.Subnet}} {{end}}' 2>/dev/null | tr ' ' '\n' | grep -m1 '\.' || echo "172.18.0.0/16")

export TF MINIO_ROOT_USER MINIO_ROOT_PASSWORD
export AWS_ACCESS_KEY_ID="${MINIO_ROOT_USER}" AWS_SECRET_ACCESS_KEY="${MINIO_ROOT_PASSWORD}"
export TF_VAR_s3_access_key="${MINIO_ROOT_USER}" TF_VAR_s3_secret_key="${MINIO_ROOT_PASSWORD}"
export TF_VAR_egress_cidrs="[\"${KIND_CIDR}\"]"
export TF_VAR_kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
