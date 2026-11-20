#!/usr/bin/env bash
# Резервная копия PostgreSQL в MinIO и восстановление в новый кластер модулем postgres-cnpg.
set -euo pipefail
cd "$(dirname "$0")/../.."
source stand/env.sh
NS=shop-dev
ROWS=1000

echo "==> кластер shop-db готов"
kubectl -n $NS wait cluster/shop-db --for=condition=Ready --timeout=600s
primary=$(kubectl -n $NS get cluster shop-db -o jsonpath='{.status.currentPrimary}')

echo "==> тестовые данные: $ROWS строк"
kubectl -n $NS exec "$primary" -c postgres -- psql -U postgres -d app -v ON_ERROR_STOP=1 -c \
  "create table if not exists orders(id int primary key, item text); truncate orders;
   insert into orders select g, 'item-' || g from generate_series(1, $ROWS) g;
   select pg_switch_wal();" >/dev/null

echo "==> резервная копия по требованию"
cat <<EOF | kubectl -n $NS apply -f -
apiVersion: postgresql.cnpg.io/v1
kind: Backup
metadata:
  name: shop-db-e2e-$(date +%s)
  labels: { e2e: "true" }
spec:
  cluster: { name: shop-db }
  method: plugin
  pluginConfiguration: { name: barman-cloud.cloudnative-pg.io }
EOF
backup=$(kubectl -n $NS get backup -l e2e=true -o jsonpath='{.items[-1:].metadata.name}')
kubectl -n $NS wait "backup/$backup" --for=jsonpath='{.status.phase}'=completed --timeout=600s
echo "OK: $backup completed"

objects=$(mc ls -r stand/backups/shop-dev/ | wc -l)
[[ "$objects" -gt 0 ]] || { echo "FAIL: в MinIO нет файлов копии"; exit 1; }
echo "OK: в MinIO $objects объектов (базовая копия и WAL)"

echo "==> восстановление в новый кластер shop-db-restore"
"${TF}" -chdir=tests/e2e/restore init -input=false -no-color >/dev/null
"${TF}" -chdir=tests/e2e/restore apply -input=false -no-color -auto-approve >/dev/null
kubectl -n $NS wait cluster/shop-db-restore --for=condition=Ready --timeout=900s
restored=$(kubectl -n $NS exec shop-db-restore-1 -c postgres -- psql -U postgres -d app -At -c "select count(*) from orders")
[[ "$restored" == "$ROWS" ]] || { echo "FAIL: восстановлено $restored строк из $ROWS"; exit 1; }
echo "OK: восстановлено $restored из $ROWS строк"

"${TF}" -chdir=tests/e2e/restore destroy -input=false -no-color -auto-approve >/dev/null
