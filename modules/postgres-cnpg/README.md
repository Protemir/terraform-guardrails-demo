# postgres-cnpg

PostgreSQL через оператор **CloudNativePG** с резервным копированием в S3-совместимое хранилище (MinIO) и восстановлением.

- оператор CloudNativePG и плагин **barman-cloud** (по флагу `install_operator`, один раз на кластер);
- кластер PostgreSQL (по умолчанию 17.6, два экземпляра с автоматическим переключением), метки владельца на всех подах;
- `ObjectStore` с базовыми копиями и WAL в MinIO, срок хранения (`retention`), ежедневный `ScheduledBackup` и первая копия сразу после создания;
- восстановление: `restore = { enabled = true, origin_cluster = "shop-db" }` создаёт новый кластер из копии исходного;
- ключи MinIO передаются **write-only** атрибутом (`data_wo`): их нет ни в плане, ни в состоянии Terraform — это проверяет e2e;
- PodMonitor для Prometheus по флагу.

С версии 1.26 CloudNativePG переносит резервное копирование во внешний плагин barman-cloud — модуль сразу использует его, а не устаревший `barmanObjectStore`.

Версия: **1.0.0** · чарты: cloudnative-pg 0.29.2 (оператор 1.30.2), plugin-barman-cloud 0.9.0 (v0.16.0). Плагину нужен cert-manager (модуль `ingress`).

## Пример

```hcl
module "shop_db" {
  source = "git::https://github.com/Protemir/terraform-guardrails-demo.git//modules/postgres-cnpg?ref=v1.0.0"

  name             = "shop-db"
  namespace        = module.shop_ns.name
  labels           = module.shop_ns.labels
  install_operator = true

  backup = {
    endpoint = "http://minio:9000"
    bucket   = "backups"
    path     = "shop-dev"
  }
  s3_access_key = var.s3_access_key # ephemeral, из секретов CI
  s3_secret_key = var.s3_secret_key
}
```

Восстановление проверяется в e2e: 1000 строк → резервная копия → новый кластер → `count(*) = 1000` ([tests/e2e/backup-restore.sh](../../tests/e2e/backup-restore.sh)).

<!-- BEGIN_TF_DOCS -->
### Входы

| Имя | Описание | Тип | По умолчанию |
|---|---|---|---|
| `name` | Имя кластера PostgreSQL. | `string` | **обязательный** |
| `namespace` | Пространство имён приложения (обычно выход модуля app-namespace). | `string` | **обязательный** |
| `labels` | Метки кластера и его подов (owner, environment, cost-center). | `map(string)` | `{}` |
| `instances` | Число экземпляров: 1 — без реплик, 2+ — с автоматическим переключением. | `number` | `2` |
| `image` | Образ PostgreSQL CloudNativePG. | `string` | `"ghcr.io/cloudnative-pg/postgresql:17.6"` |
| `storage_size` | Размер тома каждого экземпляра. | `string` | `"1Gi"` |
| `storage_class` | StorageClass; пустая строка — класс по умолчанию. | `string` | `""` |
| `database` | Имя базы приложения. | `string` | `"app"` |
| `database_owner` | Владелец базы; пароль оператор кладёт в секрет &lt;name&gt;-app. | `string` | `"app"` |
| `resources` | Запросы и лимиты контейнера PostgreSQL. | `object(…)` | `{}` |
| `postgresql_parameters` | Параметры postgresql.conf. | `map(string)` | `{}` |
| `pod_monitor` | Создать PodMonitor для Prometheus (нужны CRD prometheus-operator). | `bool` | `false` |
| `backup` | Резервное копирование в S3-совместимое хранилище (MinIO). | `object(…)` | `{}` |
| `s3_access_key` | Ключ доступа к хранилищу (write-only, в состояние не попадает). Не нужен, если задан backup.s3_secret_name. 🔒 | `string` | `null` |
| `s3_secret_key` | Секретный ключ хранилища (write-only, в состояние не попадает). 🔒 | `string` | `null` |
| `s3_credentials_revision` | Увеличьте, чтобы перезаписать ключи в секрете после ротации. | `number` | `1` |
| `restore` | Создать кластер восстановлением из резервной копии другого кластера. | `object(…)` | `{}` |
| `install_operator` | Установить оператор CloudNativePG и плагин barman-cloud (один раз на кластер Kubernetes). | `bool` | `false` |
| `operator_namespace` | Пространство имён оператора. | `string` | `"cnpg-system"` |
| `operator_chart_version` | Версия чарта cloudnative-pg. | `string` | `"0.29.2"` |
| `barman_plugin_chart_version` | Версия чарта plugin-barman-cloud. | `string` | `"0.9.0"` |
| `timeout` | Сколько секунд ждать готовности кластера. | `number` | `900` |

### Выходы

| Имя | Описание |
|---|---|
| `cluster_name` | Имя кластера CloudNativePG. |
| `rw_host` | Адрес основного экземпляра (чтение и запись). |
| `ro_host` | Адрес реплик (только чтение). |
| `app_secret_name` | Секрет с логином, паролем и URI для приложения (создаёт оператор). |
| `object_store` | Имя ObjectStore с резервными копиями — для восстановления другим кластером. |
<!-- END_TF_DOCS -->
