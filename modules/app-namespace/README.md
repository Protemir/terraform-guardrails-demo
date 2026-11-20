# app-namespace

Пространство имён приложения с безопасными настройками по умолчанию:

- метки `owner`, `environment`, `cost-center` на всех объектах;
- Pod Security Admission `restricted` — привилегированные поды не запустятся;
- ResourceQuota (CPU, память, хранилище, число подов) и запрет `LoadBalancer`/`NodePort` через квоту;
- LimitRange — лимиты по умолчанию для контейнеров, которые их не указали;
- сетевые политики «запрещено всё, кроме разрешённого»: default-deny на вход и выход, разрешены трафик внутри пространства имён, DNS, вход из перечисленных пространств имён (ingress-контроллер, мониторинг, операторы), выход на перечисленные адреса и к API Kubernetes — по флагу;
- роли `developer` и `viewer` (без доступа к секретам) и привязки к группам.

Версия: **1.0.0** · провайдер `hashicorp/kubernetes` >= 2.38, < 4 · Terraform >= 1.11 или OpenTofu >= 1.11.

## Пример

```hcl
module "shop_ns" {
  source = "git::https://github.com/Protemir/terraform-guardrails-demo.git//modules/app-namespace?ref=v1.0.0"

  name                    = "shop-dev"
  environment             = "dev"
  owner                   = "team-shop"
  cost_center             = "cc-1042"
  ingress_from_namespaces = ["traefik", "monitoring"]
  developer_groups        = ["shop-developers"]
}
```

Полный пример: [examples/basic](examples/basic). Тесты: `terraform test` (7 сценариев, без кластера).

<!-- BEGIN_TF_DOCS -->
### Входы

| Имя | Описание | Тип | По умолчанию |
|---|---|---|---|
| `name` | Имя пространства имён: &lt;система&gt;-&lt;окружение&gt;, например shop-dev. | `string` | **обязательный** |
| `environment` | Окружение: dev, stage или prod. | `string` | **обязательный** |
| `owner` | Команда-владелец (метка owner). | `string` | **обязательный** |
| `cost_center` | Центр затрат (метка cost-center). | `string` | **обязательный** |
| `labels` | Дополнительные метки для всех объектов модуля. | `map(string)` | `{}` |
| `pod_security_level` | Уровень Pod Security Admission: restricted или baseline. | `string` | `"restricted"` |
| `quota` | Квота пространства имён. | `object(…)` | `{}` |
| `container_defaults` | LimitRange: значения по умолчанию и максимум для контейнера. | `object(…)` | `{}` |
| `ingress_from_namespaces` | Пространства имён, из которых разрешён входящий трафик (ingress-контроллер, мониторинг, операторы). | `list(string)` | `[]` |
| `egress_cidrs` | Внешние адреса, куда разрешён исходящий трафик (например, объектное хранилище для резервных копий). | `list(string)` | `[]` |
| `allow_kube_api` | Разрешить подам обращаться к API Kubernetes (порты 443/6443). | `bool` | `false` |
| `developer_groups` | Группы с ролью developer (чтение, перезапуск подов, масштабирование). | `list(string)` | `[]` |
| `viewer_groups` | Группы с ролью viewer (только чтение, без секретов). | `list(string)` | `[]` |

### Выходы

| Имя | Описание |
|---|---|
| `name` | Имя созданного пространства имён. |
| `labels` | Метки, которые модуль проставил объектам (owner, environment, cost-center и служебные). |
| `network_policies` | Созданные сетевые политики. |
<!-- END_TF_DOCS -->
