#!/usr/bin/env bash
# Удаляет стенд. Состояние и резервные копии в томе stand-minio сохраняются,
# пока не передан флаг --purge.
set -euo pipefail
CLUSTER="${CLUSTER:-stand}"
kind delete cluster --name "${CLUSTER}" || true
docker rm -f minio >/dev/null 2>&1 || true
if [[ "${1:-}" == "--purge" ]]; then
  docker volume rm stand-minio >/dev/null 2>&1 || true
  rm -f "$(dirname "$0")/../.stand.env"
fi
