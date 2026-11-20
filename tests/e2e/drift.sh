#!/usr/bin/env bash
# Сравнивает код с фактическим состоянием стенда. Пишет drift.md и выход drift=true|false.
set -euo pipefail
cd "$(dirname "$0")/../.."
source stand/env.sh

"${TF}" -chdir=live/stand init -input=false -no-color -reconfigure -backend-config=../../stand/backend.hcl >/dev/null
set +e
"${TF}" -chdir=live/stand plan -input=false -no-color -lock-timeout=120s -detailed-exitcode > drift.txt 2>&1
code=$?
set -e

out="${GITHUB_OUTPUT:-/dev/stdout}"
case $code in
  0) echo "drift=false" >> "$out"; echo "Расхождений нет"; exit 0 ;;
  2) echo "drift=true" >> "$out" ;;
  *) cat drift.txt; exit 1 ;;
esac

run_url="${GITHUB_SERVER_URL:-}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-}"
{
  echo "Ежедневная проверка нашла ресурсы, которые на стенде отличаются от кода в \`main\`."
  echo
  echo "**$(grep -E '^Plan:' drift.txt || echo 'Plan: см. журнал')**"
  echo
  echo "| Ресурс | Что произойдёт при применении кода |"
  echo "|---|---|"
  grep -E '^  # .* (will be|must be)' drift.txt | sed -E 's/^  # ([^ ]+) (.*)$/| `\1` | \2 |/' | head -50
  echo
  echo "Что делать: если правку на стенде сделали намеренно — перенесите её в код через pull request;"
  echo "если нет — запустите workflow **apply**, он вернёт стенд к коду после подтверждения."
  echo
  echo "<details><summary>План</summary>"
  echo
  echo '```diff'
  sed -n '/Terraform will perform/,/^Plan:/p' drift.txt | sed -E 's/^(\s*)([+~-]) /\2\1 /; s/^~/!/' | head -300
  echo '```'
  echo "</details>"
  echo
  echo "Запуск: ${run_url}"
} > drift.md
cat drift.md
