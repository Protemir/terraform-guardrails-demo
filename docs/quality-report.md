# Отчёт о качестве пакета политик

Дата прогона: 2026-11-20. Команда: `./ci/scan-corpus.sh` (её же запускает workflow **corpus**). Инструменты: наши правила Rego через Conftest (OPA), Checkov 3.4.6, Trivy 0.76.2.

## TerraGoat: все ли файлы с намеренными ошибками найдены

Критерий ТЗ: «найдены нарушения во всех файлах с намеренными ошибками для AWS, Azure и GCP». Файлом с ошибками считаем каждый `.tf`, где объявлен хотя бы один ресурс (провайдеры, переменные и выходы не в счёт).

| Облако | Файлов с ресурсами | Найдено хоть одним инструментом | Нашли наши правила (OPA) | Нарушений OPA (из них критичных) | Checkov | Trivy | Время OPA, с |
|---|---|---|---|---|---|---|---|
| AWS | 10 | **10** | 8 | 54 (3) | 215 | 115 | 0 |
| AZURE | 8 | **8** | 5 | 22 (4) | 174 | 90 | 0 |
| GCP | 5 | **5** | 5 | 13 (3) | 56 | 48 | 0 |

Нарушения найдены в **каждом** файле с намеренными ошибками.

Не считаются файлами с ошибками: `azure/random.tf` — генератор случайного суффикса имён (random_integer), облачных ресурсов нет; `azure/policies.tf` — определение и назначение Azure Policy с эффектом audit — служебный ресурс без ошибки конфигурации; Checkov и Trivy тоже ничего не находят.

<details><summary>По файлам</summary>

| Файл | OPA | Checkov | Trivy |
|---|---|---|---|
| aws/db-app.tf | 4 | 24 | 13 |
| aws/ec2.tf | 4 | 23 | 20 |
| aws/elb.tf | 0 | 3 | 1 |
| aws/es.tf | 1 | 14 | 5 |
| aws/iam.tf | 0 | 7 | 1 |
| aws/kms.tf | 2 | 2 | 1 |
| aws/lambda.tf | 2 | 8 | 1 |
| aws/neptune.tf | 2 | 9 | 3 |
| aws/rds.tf | 29 | 82 | 20 |
| aws/s3.tf | 5 | 31 | 34 |
| azure/application_gateway.tf | 0 | 3 | 0 |
| azure/key_vault.tf | 0 | 9 | 5 |
| azure/mssql.tf | 8 | 68 | 33 |
| azure/networking.tf | 4 | 4 | 8 |
| azure/resource_group.tf | 1 | 0 | 0 |
| azure/roles.tf | 0 | 1 | 1 |
| azure/sql.tf | 5 | 22 | 13 |
| azure/storage.tf | 1 | 14 | 3 |
| gcp/big_data.tf | 4 | 16 | 10 |
| gcp/gcs.tf | 2 | 5 | 5 |
| gcp/gke.tf | 3 | 19 | 14 |
| gcp/instances.tf | 2 | 8 | 10 |
| gcp/networks.tf | 2 | 8 | 9 |

</details>

## Модули реестра: ложные срабатывания уровня «критично»

Критерий ТЗ: «не более 1 ложного нарушения уровня „критично“ на весь набор». Модули взяты из registry.terraform.io без изменений ([tests/registry/main.tf](../tests/registry/main.tf)); код модулей параметризован, поэтому значения, заданные выражениями, правила пропускают, а не угадывают.

| Модуль | Файлов | Критичных OPA | Критичных Checkov* | Критичных Trivy | Всего замечаний (OPA / Checkov / Trivy) |
|---|---|---|---|---|---|
| eks | 38 | 0 | 0 | 0 | 2 / 11 / 22 |
| gcp_network | 83 | 0 | 1 | 0 | 11 / 15 / 21 |
| rds | 56 | 0 | 0 | 0 | 2 / 18 / 0 |
| s3_bucket | 56 | 0 | 0 | 0 | 0 / 14 / 0 |
| security_group | 437 | 0 | 0 | 0 | 0 / 2 / 0 |
| vpc | 25 | 0 | 0 | 0 | 0 / 3 / 0 |

\* критичными у Checkov считаются проверки из [ci/checkov-critical.txt](../ci/checkov-critical.txt), у Trivy — уровень CRITICAL, кроме [ci/trivy-noncritical.txt](../ci/trivy-noncritical.txt): на модуле EKS Trivy даёт 11 ложных «критичных» (публичная точка API при `endpoint_public_access = false`, egress в интернет). Этот риск проверяет наше правило PUB-011 по итоговым значениям плана.

Критичные срабатывания для ручного разбора:

- gcp_network/main.tf: checkov:CKV_GCP_2 — верное срабатывание: подмодуль fabric-net-firewall по умолчанию создаёт правило SSH из 0.0.0.0/0 (ssh_source_ranges = ["0.0.0.0/0"])
