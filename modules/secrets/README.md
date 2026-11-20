# secrets

Хранение секретов в Git без открытого текста: контроллер **Sealed Secrets** и объекты `SealedSecret`.

- контроллер с именем по умолчанию для `kubeseal`, ротация ключа шифрования раз в 30 дней;
- секреты приложений передаются шифртекстом (`kubeseal --raw`), расшифровать его может только контроллер в кластере;
- проверка на входе: открытое значение вместо шифртекста не пройдёт валидацию модуля;
- область действия `strict` по умолчанию: шифртекст привязан к имени и пространству имён.

Если у заказчика есть Vault или облачный менеджер секретов, вместо Sealed Secrets подключается External Secrets Operator — интерфейс модуля (имя → пространство имён → секрет) сохраняется. Обсуждаем на этапе 1.

Версия: **1.0.0** · чарт sealed-secrets 2.22.0 (контроллер 0.41.2).

## Пример

```bash
echo -n "$API_TOKEN" | kubeseal --raw --namespace shop-dev --name shop-api
```

```hcl
module "secrets" {
  source = "git::https://github.com/Protemir/terraform-guardrails-demo.git//modules/secrets?ref=v1.0.0"

  sealed_secrets = {
    "shop-api" = {
      namespace      = "shop-dev"
      encrypted_data = { API_TOKEN = "AgBy3i4OJSWK+PiTySYZZA9rO43cGDEq0P1Ri9rBAP0Tf..." }
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
### Входы

| Имя | Описание | Тип | По умолчанию |
|---|---|---|---|
| `install_controller` | Установить контроллер Sealed Secrets (один раз на кластер). | `bool` | `true` |
| `namespace` | Пространство имён контроллера; kube-system — значение по умолчанию для kubeseal. | `string` | `"kube-system"` |
| `chart_version` | Версия чарта sealed-secrets. | `string` | `"2.22.0"` |
| `key_renew_period` | Период ротации ключа шифрования контроллера. | `string` | `"720h"` |
| `service_monitor` | Создать ServiceMonitor контроллера (нужны CRD prometheus-operator). | `bool` | `false` |
| `sealed_secrets` | Зашифрованные секреты: имя =&gt; пространство имён и шифртекст из kubeseal. | `map(…)` | `{}` |

### Выходы

| Имя | Описание |
|---|---|
| `controller_name` | Имя контроллера (флаг --controller-name для kubeseal). |
| `controller_namespace` | Пространство имён контроллера (флаг --controller-namespace для kubeseal). |
| `seal_command` | Как зашифровать значение для переменной sealed_secrets. |
| `secret_names` | Созданные секреты. |
<!-- END_TF_DOCS -->
