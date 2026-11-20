# Подключение конвейера к новому репозиторию

Цель ТЗ — не больше часа без помощи исполнителя. На практике — около 15 минут.

## 1. Workflow

Создайте `.github/workflows/iac.yml`:

```yaml
name: iac
on:
  pull_request:
    branches: [main]
permissions:
  contents: read
  pull-requests: write
jobs:
  iac:
    uses: Protemir/terraform-guardrails-demo/.github/workflows/iac-checks.yml@v1
    with:
      root: infra/prod          # каталог корневого модуля, для которого строится план
      kind: false               # true — если модули работают с Kubernetes и нужен kind для плана
      backend-config: ""        # путь к -backend-config, пусто — локальное состояние для плана
    secrets: inherit
```

Для облачных провайдеров план строится с теми учётными данными, которые репозиторий уже передаёт в CI. Политики облачных ресурсов (AWS, Azure, GCP) работают по тому же JSON-плану.

## 2. Защита ветки

Settings → Branches → Add rule для `main`:

- Require a pull request before merging;
- Require status checks to pass → добавьте **iac / report**;
- Do not allow bypassing the above settings.

Или одной командой:

```bash
gh api -X PUT repos/<org>/<repo>/branches/main/protection --input - <<'EOF'
{"required_status_checks":{"strict":true,"contexts":["iac / report"]},
 "enforce_admins":true,"required_pull_request_reviews":null,"restrictions":null}
EOF
```

## 3. Исключения и настройки (по желанию)

- `policies/exceptions.yaml` в корне репозитория — исключения именно этого репозитория (формат — в файле этого репозитория).
- `policies/config.yaml` — свои списки разрешённых источников модулей, реестров образов, обязательных меток.

## 4. Проверка

Откройте pull request с заведомым нарушением, например:

```hcl
resource "kubernetes_service_v1" "probe" {
  metadata { name = "probe" }
  spec { type = "LoadBalancer" }
}
```

В комментарии появится `PUB-001` со ссылкой на строку, статус **iac / report** станет красным, кнопка слияния — недоступной.

## Ручное применение и drift

- [apply.yml](../.github/workflows/apply.yml): Settings → Environments → `stand` → Required reviewers. Запуск — Actions → apply → Run workflow; применение начнётся после подтверждения.
- [drift.yml](../.github/workflows/drift.yml): нужен раннер с доступом к инфраструктуре (переменная `STAND_RUNNER` = метка self-hosted раннера). Расхождения приходят issue с меткой `drift`, после исправления issue закрывается автоматически.

## GitLab CI

Те же шаги — это обычные команды и контейнеры (`conftest`, `checkov`, `trivy`, `tflint`, `node ci/report.mjs`); шаблон `.gitlab-ci.yml` с комментарием в merge request через API GitLab — опция этапа 2.
