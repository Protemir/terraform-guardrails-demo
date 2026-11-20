#!/usr/bin/env bash
# Приложение доступно по HTTPS через Traefik, сертификат выпустил cert-manager от CA стенда,
# HTTP перенаправляется на HTTPS.
set -euo pipefail
HOST=shop.127.0.0.1.nip.io

kubectl -n shop-dev rollout status deployment/web --timeout=180s
kubectl -n shop-dev wait certificate/web-tls --for=condition=Ready --timeout=180s

for _ in $(seq 1 30); do
  code=$(curl -sk -o /dev/null -w '%{http_code}' --resolve "$HOST:8443:127.0.0.1" "https://$HOST:8443/" || true)
  [[ "$code" == "200" ]] && break
  sleep 2
done
[[ "$code" == "200" ]] || { echo "FAIL: HTTPS вернул $code"; exit 1; }
echo "OK: https://$HOST:8443/ → 200"

issuer=$(echo | openssl s_client -connect 127.0.0.1:8443 -servername "$HOST" 2>/dev/null | openssl x509 -noout -issuer)
echo "$issuer" | grep -q "stand-ca" || { echo "FAIL: сертификат не от CA стенда: $issuer"; exit 1; }
echo "OK: сертификат выпущен $issuer"

redirect=$(curl -s -o /dev/null -w '%{http_code}' --resolve "$HOST:8080:127.0.0.1" "http://$HOST:8080/")
[[ "$redirect" =~ ^30[1278]$ ]] || { echo "FAIL: HTTP не перенаправляется ($redirect)"; exit 1; }
echo "OK: HTTP → HTTPS ($redirect)"
