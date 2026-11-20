#!/usr/bin/env bash
# Повторный план после применения должен быть пустым (критерий приёмки «Модули»).
set -euo pipefail
cd "$(dirname "$0")/../.."
source stand/env.sh

set +e
"${TF}" -chdir=live/stand plan -input=false -no-color -detailed-exitcode > /tmp/idempotency.txt
code=$?
set -e
case $code in
  0) echo "OK: повторный план без изменений"; grep -E "^No changes" /tmp/idempotency.txt ;;
  2) echo "FAIL: после применения план не пустой"; grep -E "^  # |^Plan:" /tmp/idempotency.txt; exit 1 ;;
  *) cat /tmp/idempotency.txt; exit 1 ;;
esac
