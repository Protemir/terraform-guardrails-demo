# ns-monitoring

Подключение пространства имён к **Prometheus** и **Grafana**.

- `ServiceMonitor` для сервисов приложения с меткой `metrics=enabled`;
- `PrometheusRule` с оповещениями пространства имён: частые перезапуски, квота занята больше чем на 90 %, под не готов дольше 10 минут, упор в лимит CPU; в оповещении есть метка `owner` для маршрутизации команде;
- панель Grafana (CPU, память, использование квоты, перезапуски), её подхватывает sidecar Grafana;
- по флагу `install_stack` — сам kube-prometheus-stack (один раз на кластер), настроенный видеть объекты мониторинга всех пространств имён.

Версия: **1.0.0** · чарт kube-prometheus-stack 93.5.0.

## Пример

```hcl
module "shop_monitoring" {
  source = "git::https://github.com/Protemir/terraform-guardrails-demo.git//modules/ns-monitoring?ref=v1.0.0"

  namespace = module.shop_ns.name
  labels    = module.shop_ns.labels
}
```

Для полного наблюдения (журналы, трассы, SLO) этот модуль стыкуется с платформой наблюдаемости: [Protemir/observability-platform-demo](https://github.com/Protemir/observability-platform-demo).

<!-- BEGIN_TF_DOCS -->
### Входы

| Имя | Описание | Тип | По умолчанию |
|---|---|---|---|
| `namespace` | Пространство имён приложения, которое подключаем к мониторингу. | `string` | **обязательный** |
| `labels` | Метки объектов (owner, environment, cost-center); owner попадает в оповещения для маршрутизации. | `map(string)` | `{}` |
| `service_selector` | Метки сервисов, с которых собирать метрики. | `map(string)` | `{ metrics = "enabled" }` |
| `metrics_port` | Имя порта сервиса с метриками. | `string` | `"metrics"` |
| `metrics_path` | Путь метрик. | `string` | `"/metrics"` |
| `alerts` | Пороги оповещений пространства имён. | `object(…)` | `{}` |
| `dashboard` | Создать панель Grafana для пространства имён. | `bool` | `true` |
| `dashboard_folder` | Папка Grafana для панели. | `string` | `"Приложения"` |
| `install_stack` | Установить kube-prometheus-stack (один раз на кластер). | `bool` | `false` |
| `monitoring_namespace` | Пространство имён стека мониторинга. | `string` | `"monitoring"` |
| `stack_chart_version` | Версия чарта kube-prometheus-stack. | `string` | `"93.5.0"` |
| `alertmanager_enabled` | Включить Alertmanager в стеке. | `bool` | `false` |
| `retention` | Срок хранения метрик Prometheus. | `string` | `"7d"` |

### Выходы

| Имя | Описание |
|---|---|
| `alert_names` | Оповещения, которые получает пространство имён. |
| `monitoring_namespace` | Пространство имён Prometheus и Grafana (для сетевой политики приложения). |
<!-- END_TF_DOCS -->
