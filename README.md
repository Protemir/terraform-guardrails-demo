# terraform-guardrails-demo

> **Демо** студии [TEMIRLAB](https://temirlab.com) к задаче AstanaHub «Библиотека модулей Terraform и автоматическая проверка политик инфраструктуры как кода в CI». Витрина: [temirlab.com/demo/terraform](https://temirlab.com/demo/terraform/).

Три части, которые работают вместе:

1. **Библиотека модулей** для типовой платформы приложений на Kubernetes — 5 модулей с README, примерами и тестами (`terraform test` на Terraform и OpenTofu).
2. **Пакет политик** — 58 правил на Rego (OPA/Conftest) по JSON-плану, каждое с описанием, уровнем и примером нарушения, плюс встроенные проверки Checkov и Trivy, линтер TFLint.
3. **Конвейер CI** на GitHub Actions — подключается к любому репозиторию одной строкой `uses:`; критичное нарушение блокирует слияние, причина и строка — в комментарии к pull request.

Облачные учётные записи не используются: стенд — kind + MinIO, всё поднимается одной командой.

## Что уже работает

| Требование ТЗ | Где смотреть |
|---|---|
| 5 модулей: пространство имён (квоты, лимиты, сеть default-deny, RBAC), ingress + cert-manager, PostgreSQL CloudNativePG с копиями в MinIO и восстановлением, Sealed Secrets, мониторинг пространства имён | [modules/](modules) |
| Не меньше 30 правил с описанием, уровнем и примером | [docs/RULES.md](docs/RULES.md) — 58 правил, 10 классов |
| fmt, validate, TFLint, Checkov, Trivy, Conftest по плану, комментарий с планом и нарушениями | [.github/workflows/iac-checks.yml](.github/workflows/iac-checks.yml) |
| Критичное нарушение блокирует слияние, указаны причина и строка | демо-PR с нарушениями (ссылка ниже) |
| Применение только после ручного подтверждения | [apply.yml](.github/workflows/apply.yml), окружение `stand` с обязательным ревьюером |
| Исключения в коде с обоснованием и сроком | [policies/exceptions.yaml](policies/exceptions.yaml), правила EXC-001/EXC-002 |
| Ежедневная проверка расхождений с issue | [drift.yml](.github/workflows/drift.yml) |
| Стенд с нуля одной командой, состояние в MinIO с блокировкой | [stand/up.sh](stand/up.sh), [stand/backend.hcl](stand/backend.hcl) |
| Применение на чистом стенде, повторный план без изменений, резервная копия и восстановление | [e2e.yml](.github/workflows/e2e.yml), [tests/e2e](tests/e2e) |
| TerraGoat и модули реестра: найденные нарушения и ложные срабатывания | [docs/quality-report.md](docs/quality-report.md) |
| Подключение к новому репозиторию | [docs/onboarding.md](docs/onboarding.md) |
| Перечень инструментов с лицензиями | [docs/tools.md](docs/tools.md) |

## Быстрый старт

```bash
# стенд: kind + MinIO + все модули (4 vCPU, 8 ГБ RAM)
./stand/up.sh                 # Terraform
TF=tofu ./stand/up.sh         # OpenTofu

# проверки локально
node ci/test-policies.mjs     # каждое правило на своём примере
conftest verify -p policies   # юнит-тесты библиотеки Rego
(cd modules/app-namespace && terraform init -backend=false && terraform test)

./stand/down.sh               # удалить стенд (состояние и копии в томе MinIO остаются)
```

## Как устроена проверка pull request

```
pull request ─┬─ static: fmt · validate · TFLint · Checkov · Trivy
              └─ plan:   kind + MinIO → terraform plan → JSON → Conftest (58 правил)
                              │
                         report: сводка → комментарий к PR (нарушения со ссылкой на строку, план)
                              │
                 critical? ── да → статус «report» красный → слияние запрещено (branch protection)
```

Блокируют слияние: правила уровня «критично» (17 правил: публичный доступ, привилегированные контейнеры, cluster-admin, `*:*` в IAM, модули без версии или из непроверенного источника, удалённые API Kubernetes, неверно оформленное исключение), уровень CRITICAL у Trivy (кроме шумных проверок из [ci/trivy-noncritical.txt](ci/trivy-noncritical.txt)) и проверки Checkov из [ci/checkov-critical.txt](ci/checkov-critical.txt). Остальное попадает в комментарий без блокировки.

## Структура

```
modules/           5 модулей: README, examples/basic, tests/*.tftest.hcl, локальные чарты для CRD
policies/          rules/*.rego (58 правил), lib/, main.rego, examples/ (bad_/good_ на каждое правило),
                   tests/ (юнит-тесты), config.yaml (списки разрешённого), exceptions.yaml
live/stand/        корневой модуль стенда: платформа + приложение shop-dev на модулях библиотеки
stand/             up.sh / down.sh, kind.yaml, backend.hcl (MinIO + use_lockfile)
ci/                report.mjs (комментарий и решение), test-policies.mjs, scan-corpus.sh, генераторы документации
tests/e2e/         идемпотентность, HTTPS, сетевые политики, секреты вне состояния, копия и восстановление, drift
.github/workflows  iac-checks (переиспользуемый), pr, tests, e2e, apply, drift, corpus
```

## Лицензия

Код этого репозитория — лицензия на ознакомление, использование по договору с TEMIRLAB ([LICENSE](LICENSE)). Сторонние компоненты — открытое ПО на условиях их собственных лицензий, перечень в [docs/tools.md](docs/tools.md).
