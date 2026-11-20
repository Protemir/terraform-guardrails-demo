#!/usr/bin/env bash
# Поднимает стенд с нуля одной командой: kind + MinIO + все модули библиотеки.
#   ./stand/up.sh            — Terraform
#   TF=tofu ./stand/up.sh    — OpenTofu
# Нужны: docker, kind, kubectl, terraform или tofu. Ресурсы: 4 vCPU, 8 ГБ RAM, 20 ГБ диска.
set -euo pipefail
cd "$(dirname "$0")/.."

CLUSTER="${CLUSTER:-stand}"
MINIO_IMAGE="${MINIO_IMAGE:-cgr.dev/chainguard/minio:latest}"

echo "==> kind: кластер ${CLUSTER}"
if ! kind get clusters 2>/dev/null | grep -qx "${CLUSTER}"; then
  kind create cluster --name "${CLUSTER}" --config stand/kind.yaml --wait 120s
fi
kubectl config use-context "kind-${CLUSTER}" >/dev/null

# Ключи MinIO, сеть kind, переменные Terraform.
source stand/env.sh

echo "==> MinIO в сети kind"
if ! docker ps --format '{{.Names}}' | grep -qx minio; then
  docker rm -f minio >/dev/null 2>&1 || true
  # Образ Chainguard собран из исходников MinIO (официальные образы больше не публикуются).
  docker run -d --name minio --network kind --user 0:0 -p 9000:9000 -p 9001:9001 \
    -e MINIO_ROOT_USER -e MINIO_ROOT_PASSWORD \
    -v stand-minio:/data "${MINIO_IMAGE}" server /data --console-address :9001 >/dev/null
fi
for _ in $(seq 1 30); do
  curl -sf http://localhost:9000/minio/health/live >/dev/null && break
  sleep 1
done
mc mb --ignore-existing stand/tfstate stand/backups >/dev/null
mc version enable stand/tfstate >/dev/null

echo "==> ${TF} apply live/stand"
"${TF}" -chdir=live/stand init -input=false -reconfigure -backend-config=../../stand/backend.hcl >/dev/null
"${TF}" -chdir=live/stand apply -input=false -auto-approve "$@"

echo
echo "Стенд готов: https://shop.127.0.0.1.nip.io:8443 (CA стенда), MinIO: http://localhost:9001"
