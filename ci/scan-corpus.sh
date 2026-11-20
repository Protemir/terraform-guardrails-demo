#!/usr/bin/env bash
# Прогон пакета политик по открытому коду (критерии «TerraGoat» и «Ложные срабатывания»):
#   1) bridgecrewio/terragoat — учебный код с намеренными ошибками для AWS, Azure, GCP;
#   2) популярные модули реестра registry.terraform.io (tests/registry/main.tf) — код без внесённых ошибок.
# Итог: results/corpus/*.json и docs/quality-report.md (node ci/quality-report.mjs).
#
# Инструменты берутся из PATH; если их нет — из Docker-образов (USE_DOCKER=1).
set -euo pipefail
cd "$(dirname "$0")/.."

TERRAGOAT_REF="${TERRAGOAT_REF:-729f8da62c6a85ce4af5ad3d123de97776d954c4}"
OUT=results/corpus
WORK=.tmp/corpus
mkdir -p "$OUT" "$WORK"

if [[ "${USE_DOCKER:-}" == "1" ]] || ! command -v conftest >/dev/null; then
  W="$(pwd -W 2>/dev/null || pwd)"
  conftest() { docker run --rm -v "$W:/w" -w /w openpolicyagent/conftest:v0.71.1 "$@"; }
  checkov() { docker run --rm -v "$W:/w" -w /w bridgecrew/checkov:3.4.6 "$@"; }
  trivy() { docker run --rm -v "$W:/w" -w /w aquasec/trivy:0.76.2 "$@"; }
  tf() { docker run --rm -v "$W:/w" -w /w/tests/registry hashicorp/terraform:1.17.2 "$@"; }
else
  tf() { terraform -chdir=tests/registry "$@"; }
fi

echo "==> TerraGoat @ ${TERRAGOAT_REF:0:7}"
if [[ ! -d "$WORK/terragoat/.git" ]]; then
  git clone -q https://github.com/bridgecrewio/terragoat.git "$WORK/terragoat"
fi
git -C "$WORK/terragoat" checkout -q "$TERRAGOAT_REF"

echo "==> модули реестра"
tf get -update >/dev/null
rm -rf "$WORK/registry" && mkdir -p "$WORK/registry"
for m in tests/registry/.terraform/modules/*/; do
  name=$(basename "$m")
  [[ "$name" == *.* ]] && continue # вложенные подмодули (vpc.endpoints и т.п.) входят в родителя
  cp -r "$m" "$WORK/registry/$name"
done

scan() { # $1 — метка, $2 — каталог
  local label=$1 dir=$2 t0 t1
  echo "   $label: $dir"
  t0=$(date +%s)
  mapfile -t files < <(find "$dir" -name '*.tf' -not -path '*/.terraform/*' -not -path '*/examples/*' -not -path '*/test*/*' | sort)
  conftest test --parser hcl2 -p policies --data policies/config.yaml -o json --no-fail "${files[@]}" > "$OUT/$label.conftest.json"
  t1=$(date +%s)
  checkov -d "$dir" --framework terraform -o json --soft-fail --quiet --skip-path examples --skip-path tests --skip-path test > "$OUT/$label.checkov.json" || true
  trivy config --format json --exit-code 0 --quiet --skip-dirs "$dir/examples" "$dir" > "$OUT/$label.trivy.json" || true
  echo "{\"conftest_seconds\": $((t1 - t0)), \"files\": ${#files[@]}}" > "$OUT/$label.meta.json"
}

for cloud in aws azure gcp; do
  scan "terragoat-$cloud" "$WORK/terragoat/terraform/$cloud"
done
for d in "$WORK"/registry/*/; do
  scan "registry-$(basename "$d")" "${d%/}"
done

node ci/quality-report.mjs
