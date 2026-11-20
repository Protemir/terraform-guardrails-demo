# Журнал изменений

Формат — [Keep a Changelog](https://keepachangelog.com/ru/1.1.0/), версии — [SemVer](https://semver.org/lang/ru/). Модули версионируются тегами `v<major>.<minor>.<patch>` репозитория; несовместимое изменение входов модуля — новая мажорная версия.

## [1.0.0] — 2026-11-20

### Модули
- `app-namespace` 1.0.0 — пространство имён с метками, Pod Security `restricted`, квотой, LimitRange, сетевыми политиками default-deny и ролями developer/viewer.
- `ingress` 1.0.0 — Traefik 42.4.1, cert-manager v1.21.3, ClusterIssuer CA стенда и Let's Encrypt.
- `postgres-cnpg` 1.0.0 — CloudNativePG 1.30.2, плагин barman-cloud, копии и WAL в MinIO, восстановление, ключи через write-only атрибут.
- `secrets` 1.0.0 — Sealed Secrets 0.41.2, объекты SealedSecret с проверкой шифртекста.
- `ns-monitoring` 1.0.0 — ServiceMonitor, 4 оповещения пространства имён, панель Grafana, kube-prometheus-stack 93.5.0 по флагу.

### Политики
- 57 правил Rego в 10 классах, примеры bad/good на каждое правило, юнит-тесты библиотеки.
- Исключения с обоснованием, владельцем и сроком до 180 дней.

### Конвейер
- Переиспользуемый workflow `iac-checks`: fmt, validate, TFLint, Checkov, Trivy, Conftest по плану, комментарий к PR, блокировка по критичным нарушениям.
- Тесты модулей на Terraform 1.17 и OpenTofu 1.13, e2e на kind, ручное применение, ежедневный drift, отчёт по TerraGoat и модулям реестра.
