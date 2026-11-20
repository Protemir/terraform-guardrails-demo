# ingress

Входящий трафик кластера: ingress-контроллер **Traefik** и **cert-manager** с эмитентами сертификатов.

- Traefik — IngressClass `traefik` по умолчанию, HTTP перенаправляется на HTTPS, лимиты ресурсов, PodDisruptionBudget при 2+ репликах;
- cert-manager с CRD;
- собственный CA стенда (`ClusterIssuer stand-ca`) и, если указана почта, Let's Encrypt (`ClusterIssuer letsencrypt`, HTTP-01 через Traefik);
- эмитенты собраны в локальный чарт, поэтому `plan` строится на пустом кластере — без ожидания CRD.

Почему Traefik, а не ingress-nginx: с марта 2026 года ingress-nginx больше не сопровождается (объявление Kubernetes SIG Network, ноябрь 2025), новые установки на нём не рекомендуются.

Версия: **1.0.0** · провайдер `hashicorp/helm` >= 3.0, < 4 · чарты: traefik 42.4.1, cert-manager v1.21.3.

## Пример

```hcl
module "ingress" {
  source = "git::https://github.com/Protemir/terraform-guardrails-demo.git//modules/ingress?ref=v1.0.0"

  service_type = "NodePort" # на kind; в облаке — LoadBalancer
  replicas     = 1
}

# В Ingress приложения:
#   annotations = { "cert-manager.io/cluster-issuer" = module.ingress.cluster_issuer }
#   ingress_class_name = module.ingress.ingress_class_name
```

Полный пример: [examples/basic](examples/basic). Тесты: `terraform test` (5 сценариев).

<!-- BEGIN_TF_DOCS -->
### Входы

| Имя | Описание | Тип | По умолчанию |
|---|---|---|---|
| `namespace` | Пространство имён ingress-контроллера Traefik. | `string` | `"traefik"` |
| `cert_manager_namespace` | Пространство имён cert-manager. | `string` | `"cert-manager"` |
| `traefik_chart_version` | Версия чарта traefik/traefik. | `string` | `"42.4.1"` |
| `cert_manager_chart_version` | Версия чарта jetstack/cert-manager. | `string` | `"v1.21.3"` |
| `service_type` | Тип сервиса Traefik: LoadBalancer в облаке, NodePort на локальном стенде (kind). | `string` | `"LoadBalancer"` |
| `node_ports` | Порты узла для NodePort (на kind пробрасываются на localhost). | `object(…)` | `{}` |
| `replicas` | Число реплик Traefik; при 2+ включается PodDisruptionBudget. | `number` | `2` |
| `service_monitor` | Создавать ServiceMonitor для Prometheus (нужны CRD prometheus-operator). | `bool` | `false` |
| `stand_ca_enabled` | Создать собственный CA и ClusterIssuer на его основе (локальный стенд, внутренние сервисы). | `bool` | `true` |
| `stand_ca_issuer_name` | Имя ClusterIssuer собственного CA. | `string` | `"stand-ca"` |
| `acme_email` | Почта для Let's Encrypt; пустая строка — ACME-эмитент не создаётся. | `string` | `""` |
| `acme_server` | Адрес ACME-сервера. | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` |

### Выходы

| Имя | Описание |
|---|---|
| `ingress_class_name` | Имя IngressClass для объектов Ingress. |
| `cluster_issuer` | ClusterIssuer для аннотации cert-manager.io/cluster-issuer. |
| `namespace` | Пространство имён ingress-контроллера (для сетевых политик приложений). |
| `versions` | Установленные версии чартов. |
<!-- END_TF_DOCS -->
