#!/usr/bin/env bash
# «Запрещено всё, кроме разрешённого»: из чужого пространства имён к приложению не попасть,
# из своего — можно.
set -euo pipefail

probe() { # $1 — пространство имён, откуда стучимся
  kubectl -n "$1" run "probe-$RANDOM" --rm -i --restart=Never --quiet --image=curlimages/curl:8.17.0 \
    --overrides='{"spec":{"securityContext":{"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"containers":[{"name":"probe","image":"curlimages/curl:8.17.0","args":["-s","-o","/dev/null","-w","%{http_code}","--max-time","5","http://web.shop-dev.svc"],"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}},"resources":{"limits":{"cpu":"100m","memory":"64Mi"}}}]}}' \
    2>/dev/null || true
}

kubectl create namespace netpol-probe --dry-run=client -o yaml | kubectl apply -f - >/dev/null

outside=$(probe netpol-probe)
inside=$(probe shop-dev)
kubectl delete namespace netpol-probe --wait=false >/dev/null

echo "из netpol-probe: '${outside}', из shop-dev: '${inside}'"
[[ "$outside" != "200" ]] || { echo "FAIL: default-deny не работает"; exit 1; }
[[ "$inside" == "200" ]] || { echo "FAIL: трафик внутри пространства имён заблокирован"; exit 1; }
echo "OK: чужое пространство имён заблокировано, своё — разрешено"
