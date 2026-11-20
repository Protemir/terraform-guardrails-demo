#!/usr/bin/env bash
# Ключи MinIO передаются write-only атрибутом и не должны оказаться в состоянии Terraform.
set -euo pipefail
cd "$(dirname "$0")/../.."
source stand/env.sh

hits=$("${TF}" -chdir=live/stand state pull | grep -c -- "${MINIO_ROOT_PASSWORD}" || true)
[[ "$hits" == "0" ]] || { echo "FAIL: секретный ключ найден в состоянии ($hits раз)"; exit 1; }
kubectl -n shop-dev get secret shop-db-s3 -o jsonpath='{.data.ACCESS_SECRET_KEY}' | base64 -d | grep -q -- "${MINIO_ROOT_PASSWORD}" \
  || { echo "FAIL: секрет в кластере не содержит ключ"; exit 1; }
echo "OK: ключ есть в секрете Kubernetes, но не в состоянии Terraform"
