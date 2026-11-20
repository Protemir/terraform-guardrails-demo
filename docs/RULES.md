# Каталог правил

Пакет: **58 правил** на Rego (OPA/Conftest) поверх JSON-плана Terraform/OpenTofu и HCL. Файл генерируется командой `node ci/gen-rules-doc.mjs`, CI проверяет, что он актуален.

Уровень **критично** блокирует слияние pull request. Остальные уровни попадают в комментарий и не блокируют. Дополнительно работают встроенные проверки Checkov и Trivy (блокирующие из них — в `ci/checkov-critical.txt` и уровень CRITICAL у Trivy).

| Класс | Правил | Критичных |
|---|---|---|
| Публичный доступ | 11 | 9 |
| Шифрование | 7 | 0 |
| Избыточные права | 10 | 3 |
| Журналирование | 4 | 0 |
| Ограничения ресурсов | 6 | 0 |
| Обязательные метки | 3 | 0 |
| Именование | 3 | 0 |
| Версии и источники модулей | 10 | 4 |
| Резервное копирование | 2 | 0 |
| Исключения | 2 | 1 |

| ID | Уровень | Правило |
|---|---|---|
| [PUB-001](#pub-001) | критично | Service типа LoadBalancer открыт в интернет |
| [PUB-002](#pub-002) | высокий | Service типа NodePort |
| [PUB-003](#pub-003) | критично | Под в сетевом или процессном пространстве узла |
| [PUB-004](#pub-004) | критично | Публичный бакет S3 |
| [PUB-005](#pub-005) | критично | Security group открывает админ-порты или все порты всему интернету |
| [PUB-006](#pub-006) | критично | Публично доступная управляемая база данных |
| [PUB-007](#pub-007) | критично | Правило NSG Azure пускает интернет на админ-порты |
| [PUB-008](#pub-008) | высокий | Анонимный доступ к хранилищу Azure |
| [PUB-009](#pub-009) | критично | Firewall GCP пускает интернет на админ-порты |
| [PUB-010](#pub-010) | критично | Ресурс GCP выдан allUsers / allAuthenticatedUsers |
| [PUB-011](#pub-011) | критично | API управляемого Kubernetes открыт всему интернету |
| [ENC-001](#enc-001) | высокий | Ingress без TLS |
| [ENC-002](#enc-002) | высокий | Секрет Kubernetes открытым текстом в коде Terraform |
| [ENC-003](#enc-003) | высокий | Хранилище данных без шифрования |
| [ENC-004](#enc-004) | высокий | Балансировщик принимает HTTP без перенаправления на HTTPS |
| [ENC-005](#enc-005) | высокий | Хранилище Azure допускает HTTP или старый TLS |
| [ENC-006](#enc-006) | высокий | Cloud SQL без обязательного SSL |
| [ENC-007](#enc-007) | средний | Ключ KMS без ротации |
| [IAM-001](#iam-001) | критично | Привязка cluster-admin |
| [IAM-002](#iam-002) | высокий | Роль RBAC с «*» в глаголах, ресурсах или группах API |
| [IAM-003](#iam-003) | критично | Привилегированный контейнер |
| [IAM-004](#iam-004) | высокий | Разрешено повышение привилегий |
| [IAM-005](#iam-005) | высокий | Опасные Linux capabilities |
| [IAM-006](#iam-006) | средний | Контейнер может работать от root |
| [IAM-007](#iam-007) | средний | Корневая файловая система контейнера доступна на запись |
| [IAM-008](#iam-008) | средний | Токен сервисного аккаунта монтируется в под |
| [IAM-009](#iam-009) | критично | Политика IAM AWS «*» на «*» |
| [IAM-010](#iam-010) | высокий | Широкая административная роль в облаке |
| [LOG-001](#log-001) | средний | Бакет S3 без журнала доступа |
| [LOG-002](#log-002) | высокий | Журнал аудита облака неполный |
| [LOG-003](#log-003) | средний | Управляемый Kubernetes без журналов control plane |
| [LOG-004](#log-004) | средний | Балансировщик или сеть без журнала |
| [RES-001](#res-001) | высокий | Контейнер без лимитов CPU и памяти |
| [RES-002](#res-002) | средний | Контейнер без requests |
| [RES-003](#res-003) | высокий | Пространство имён без ResourceQuota |
| [RES-004](#res-004) | высокий | Пространство имён без сетевой политики «запрещено всё» |
| [RES-005](#res-005) | средний | Пространство имён без LimitRange |
| [RES-006](#res-006) | средний | Долгоживущий контейнер без проверок готовности и живости |
| [TAG-001](#tag-001) | высокий | Облачный ресурс без меток владельца, окружения и центра затрат |
| [TAG-002](#tag-002) | высокий | Объект Kubernetes без меток владельца, окружения и центра затрат |
| [TAG-003](#tag-003) | средний | Недопустимое значение окружения |
| [NAME-001](#name-001) | средний | Имя объекта Kubernetes не по соглашению |
| [NAME-002](#name-002) | средний | Имя пространства имён не заканчивается окружением |
| [NAME-003](#name-003) | средний | Имя бакета не по соглашению |
| [SRC-001](#src-001) | критично | Модуль из git или по ссылке без закреплённой версии |
| [SRC-002](#src-002) | критично | Модуль из непроверенного источника |
| [SRC-003](#src-003) | высокий | Модуль реестра без точной версии |
| [SRC-004](#src-004) | высокий | Чарт Helm без закреплённой версии |
| [SRC-005](#src-005) | критично | Чарт Helm из репозитория по HTTP или вне списка |
| [SRC-006](#src-006) | высокий | Образ контейнера без версии или с тегом latest |
| [SRC-007](#src-007) | средний | Образ из реестра вне списка |
| [SRC-008](#src-008) | высокий | Провайдер без ограничения версии |
| [SRC-009](#src-009) | высокий | Запрещённая (снятая с поддержки) версия движка |
| [SRC-010](#src-010) | критично | Удалённый API Kubernetes или устаревший тип ресурса |
| [DB-001](#db-001) | высокий | База данных без резервных копий |
| [DB-002](#db-002) | средний | База данных без защиты от удаления |
| [EXC-001](#exc-001) | критично | Исключение оформлено без обоснования, владельца или срока |
| [EXC-002](#exc-002) | средний | Просроченное исключение |

## Публичный доступ

### PUB-001

**Service типа LoadBalancer открыт в интернет** · уровень: критично · [policies/rules/pub_001.rego](../policies/rules/pub_001.rego)

Сервис LoadBalancer без load_balancer_source_ranges и без аннотации внутреннего балансировщика получает внешний адрес, доступный всем.

Как исправить: Публикуйте приложение через Ingress (модуль ingress) или задайте load_balancer_source_ranges / аннотацию internal.

Пример нарушения ([все примеры](../policies/examples/PUB-001.tf)):

```hcl
resource "kubernetes_service_v1" "bad_public_lb" {
  metadata {
    name = "web"
  }
  spec {
    type = "LoadBalancer"
  }
}
```

### PUB-002

**Service типа NodePort** · уровень: высокий · [policies/rules/pub_002.rego](../policies/rules/pub_002.rego)

NodePort открывает порт на каждом узле кластера в обход Ingress.

Как исправить: Используйте ClusterIP и Ingress.

Пример нарушения ([все примеры](../policies/examples/PUB-002.tf)):

```hcl
resource "kubernetes_service_v1" "bad_node_port" {
  metadata {
    name = "web"
  }
  spec {
    type = "NodePort"
  }
}
```

### PUB-003

**Под в сетевом или процессном пространстве узла** · уровень: критично · [policies/rules/pub_003.rego](../policies/rules/pub_003.rego)

host_network, host_pid, host_ipc или host_port дают поду прямой доступ к сети и процессам узла и выводят его из-под сетевых политик.

Как исправить: Уберите host_network / host_pid / host_ipc и host_port; публикуйте порт через Service.

Пример нарушения ([все примеры](../policies/examples/PUB-003.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_host_network" {
  metadata {
    name = "bad-host-network"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        host_network = true
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}
```

### PUB-004

**Публичный бакет S3** · уровень: критично · [policies/rules/pub_004.rego](../policies/rules/pub_004.rego)

ACL public-read / public-read-write / authenticated-read или выключенная блокировка публичного доступа делают объекты бакета доступными всем.

Как исправить: ACL private и aws_s3_bucket_public_access_block со всеми четырьмя флагами true.

Пример нарушения ([все примеры](../policies/examples/PUB-004.tf)):

```hcl
resource "aws_s3_bucket" "bad_public_acl" {
  bucket = "shop-public"
  acl    = "public-read"
}
```

### PUB-005

**Security group открывает админ-порты или все порты всему интернету** · уровень: критично · [policies/rules/pub_005.rego](../policies/rules/pub_005.rego)

Входящее правило из 0.0.0.0/0 или ::/0 на SSH, RDP, порты баз данных или на весь диапазон портов.

Как исправить: Ограничьте источник адресами VPN или бастиона.

Пример нарушения ([все примеры](../policies/examples/PUB-005.tf)):

```hcl
resource "aws_security_group" "bad_ssh_world" {
  name = "bastion"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### PUB-006

**Публично доступная управляемая база данных** · уровень: критично · [policies/rules/pub_006.rego](../policies/rules/pub_006.rego)

База получает публичный адрес (publicly_accessible, public_network_access_enabled) или пускает 0.0.0.0/0.

Как исправить: Отключите публичный доступ, подключайтесь из приватной сети.

Пример нарушения ([все примеры](../policies/examples/PUB-006.tf)):

```hcl
resource "aws_db_instance" "bad_public_db" {
  engine              = "postgres"
  instance_class      = "db.t4g.micro"
  publicly_accessible = true
}
```

### PUB-007

**Правило NSG Azure пускает интернет на админ-порты** · уровень: критично · [policies/rules/pub_007.rego](../policies/rules/pub_007.rego)

Входящее Allow-правило с источником *, Internet или 0.0.0.0/0 на SSH, RDP, порты БД или на любой порт.

Как исправить: Ограничьте source_address_prefix адресами VPN или бастиона.

Пример нарушения ([все примеры](../policies/examples/PUB-007.tf)):

```hcl
resource "azurerm_network_security_rule" "bad_rdp_any" {
  name                       = "rdp"
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = "*"
  destination_port_range     = "3389"
}
```

### PUB-008

**Анонимный доступ к хранилищу Azure** · уровень: высокий · [policies/rules/pub_008.rego](../policies/rules/pub_008.rego)

Разрешён анонимный доступ к контейнерам Blob.

Как исправить: allow_nested_items_to_be_public = false, container_access_type = private.

Пример нарушения ([все примеры](../policies/examples/PUB-008.tf)):

```hcl
resource "azurerm_storage_account" "bad_public_blobs" {
  name                            = "shopdata"
  allow_nested_items_to_be_public = true
}
```

### PUB-009

**Firewall GCP пускает интернет на админ-порты** · уровень: критично · [policies/rules/pub_009.rego](../policies/rules/pub_009.rego)

Правило INGRESS из 0.0.0.0/0 на SSH, RDP, порты БД или на все порты.

Как исправить: Ограничьте source_ranges; для SSH используйте IAP (35.235.240.0/20).

Пример нарушения ([все примеры](../policies/examples/PUB-009.tf)):

```hcl
resource "google_compute_firewall" "bad_ssh_world" {
  name          = "allow-ssh"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
```

### PUB-010

**Ресурс GCP выдан allUsers / allAuthenticatedUsers** · уровень: критично · [policies/rules/pub_010.rego](../policies/rules/pub_010.rego)

IAM-привязка для allUsers или allAuthenticatedUsers открывает ресурс любому человеку в интернете.

Как исправить: Выдавайте роли конкретным сервисным аккаунтам и группам.

Пример нарушения ([все примеры](../policies/examples/PUB-010.tf)):

```hcl
resource "google_storage_bucket_iam_member" "bad_all_users" {
  bucket = "shop-files"
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
```

### PUB-011

**API управляемого Kubernetes открыт всему интернету** · уровень: критично · [policies/rules/pub_011.rego](../policies/rules/pub_011.rego)

Публичная точка API-сервера кластера (EKS, AKS, GKE) без ограничения адресов доступна для подбора учётных данных и эксплуатации уязвимостей.

Как исправить: Закройте публичную точку или ограничьте её адресами VPN/офиса: EKS — endpoint_public_access = false или public_access_cidrs; AKS — authorized_ip_ranges; GKE — master_authorized_networks_config.

Пример нарушения ([все примеры](../policies/examples/PUB-011.tf)):

```hcl
resource "aws_eks_cluster" "bad_public_api" {
  name     = "shop"
  role_arn = "arn"
  vpc_config {
    subnet_ids = ["subnet-1", "subnet-2"]
  }
}
```

## Шифрование

### ENC-001

**Ingress без TLS** · уровень: высокий · [policies/rules/enc_001.rego](../policies/rules/enc_001.rego)

Ingress без блока tls отдаёт приложение по открытому HTTP.

Как исправить: Добавьте блок tls и аннотацию cert-manager.io/cluster-issuer (модуль ingress создаёт issuer).

Пример нарушения ([все примеры](../policies/examples/ENC-001.tf)):

```hcl
resource "kubernetes_ingress_v1" "bad_plain_http" {
  metadata {
    name = "web"
  }
  spec {
    rule {
      host = "shop.local"
    }
  }
}
```

### ENC-002

**Секрет Kubernetes открытым текстом в коде Terraform** · уровень: высокий · [policies/rules/enc_002.rego](../policies/rules/enc_002.rego)

kubernetes_secret_v1 с data хранит значение в коде и в состоянии Terraform без шифрования.

Как исправить: Используйте модуль secrets (SealedSecret): в репозиторий попадает только зашифрованное значение.

Пример нарушения ([все примеры](../policies/examples/ENC-002.tf)):

```hcl
resource "kubernetes_secret_v1" "bad_plain_secret" {
  metadata {
    name = "db"
  }
  data = {
    password = "P@ssw0rd"
  }
}
```

### ENC-003

**Хранилище данных без шифрования** · уровень: высокий · [policies/rules/enc_003.rego](../policies/rules/enc_003.rego)

Диски, базы и файловые системы создаются без шифрования при хранении.

Как исправить: encrypted / storage_encrypted = true, при необходимости — свой ключ KMS.

Пример нарушения ([все примеры](../policies/examples/ENC-003.tf)):

```hcl
resource "aws_ebs_volume" "bad_volume" {
  availability_zone = "eu-central-1a"
  size              = 20
}
```

### ENC-004

**Балансировщик принимает HTTP без перенаправления на HTTPS** · уровень: высокий · [policies/rules/enc_004.rego](../policies/rules/enc_004.rego)

Listener по HTTP, который не перенаправляет на HTTPS, отдаёт трафик без шифрования.

Как исправить: protocol = HTTPS с ssl_policy, а на порту 80 — default_action redirect на HTTPS.

Пример нарушения ([все примеры](../policies/examples/ENC-004.tf)):

```hcl
resource "aws_lb_listener" "bad_http_forward" {
  load_balancer_arn = "arn"
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "arn"
  }
}
```

### ENC-005

**Хранилище Azure допускает HTTP или старый TLS** · уровень: высокий · [policies/rules/enc_005.rego](../policies/rules/enc_005.rego)

Учётная запись хранения принимает запросы по HTTP или по TLS ниже 1.2.

Как исправить: https_traffic_only_enabled = true, min_tls_version = TLS1_2.

Пример нарушения ([все примеры](../policies/examples/ENC-005.tf)):

```hcl
resource "azurerm_storage_account" "bad_http" {
  name                       = "shopdata"
  https_traffic_only_enabled = false
  min_tls_version            = "TLS1_0"
}
```

### ENC-006

**Cloud SQL без обязательного SSL** · уровень: высокий · [policies/rules/enc_006.rego](../policies/rules/enc_006.rego)

Экземпляр Cloud SQL принимает незашифрованные подключения.

Как исправить: settings.ip_configuration.ssl_mode = ENCRYPTED_ONLY (или require_ssl = true).

Пример нарушения ([все примеры](../policies/examples/ENC-006.tf)):

```hcl
resource "google_sql_database_instance" "bad_no_ssl" {
  name             = "shop"
  database_version = "POSTGRES_16"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      require_ssl = false
    }
  }
}
```

### ENC-007

**Ключ KMS без ротации** · уровень: средний · [policies/rules/enc_007.rego](../policies/rules/enc_007.rego)

Симметричный ключ KMS / Key Vault без автоматической ротации.

Как исправить: enable_key_rotation = true (AWS), rotation_period (GCP), rotation_policy (Azure).

Пример нарушения ([все примеры](../policies/examples/ENC-007.tf)):

```hcl
resource "aws_kms_key" "bad_no_rotation" {
  description = "shop"
}
```

## Избыточные права

### IAM-001

**Привязка cluster-admin** · уровень: критично · [policies/rules/iam_001.rego](../policies/rules/iam_001.rego)

ClusterRoleBinding на cluster-admin для пользовательского субъекта даёт полный контроль над кластером.

Как исправить: Выдайте namespaced Role с нужными глаголами (модуль app-namespace создаёт роли developer и viewer).

Пример нарушения ([все примеры](../policies/examples/IAM-001.tf)):

```hcl
resource "kubernetes_cluster_role_binding_v1" "bad_dev_admin" {
  metadata {
    name = "dev-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind = "User"
    name = "developer@shop.local"
  }
}
```

### IAM-002

**Роль RBAC с «*» в глаголах, ресурсах или группах API** · уровень: высокий · [policies/rules/iam_002.rego](../policies/rules/iam_002.rego)

Подстановка «*» выдаёт права на всё, включая ресурсы, которые появятся позже.

Как исправить: Перечислите конкретные verbs, resources и api_groups.

Пример нарушения ([все примеры](../policies/examples/IAM-002.tf)):

```hcl
resource "kubernetes_cluster_role_v1" "bad_wildcard" {
  metadata {
    name = "ops"
  }
  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}
```

### IAM-003

**Привилегированный контейнер** · уровень: критично · [policies/rules/iam_003.rego](../policies/rules/iam_003.rego)

privileged = true даёт контейнеру права root на узле.

Как исправить: Уберите privileged; нужные права выдайте точечно через capabilities.

Пример нарушения ([все примеры](../policies/examples/IAM-003.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_privileged" {
  metadata {
    name = "bad-privileged"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
          security_context {
            privileged = true
          }
        }
      }
    }
  }
}
```

### IAM-004

**Разрешено повышение привилегий** · уровень: высокий · [policies/rules/iam_004.rego](../policies/rules/iam_004.rego)

Без allow_privilege_escalation = false процесс в контейнере может получить больше прав, чем у родителя (setuid).

Как исправить: security_context { allow_privilege_escalation = false }.

Пример нарушения ([все примеры](../policies/examples/IAM-004.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_escalation" {
  metadata {
    name = "bad-escalation"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}
```

### IAM-005

**Опасные Linux capabilities** · уровень: высокий · [policies/rules/iam_005.rego](../policies/rules/iam_005.rego)

SYS_ADMIN, NET_ADMIN, SYS_PTRACE, NET_RAW или ALL почти равны root на узле.

Как исправить: capabilities { drop = ["ALL"] } и добавляйте только безопасные (например NET_BIND_SERVICE).

Пример нарушения ([все примеры](../policies/examples/IAM-005.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_sys_admin" {
  metadata {
    name = "bad-sys-admin"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
          security_context {
            capabilities {
              add = ["SYS_ADMIN"]
            }
          }
        }
      }
    }
  }
}
```

### IAM-006

**Контейнер может работать от root** · уровень: средний · [policies/rules/iam_006.rego](../policies/rules/iam_006.rego)

Не задан run_as_non_root = true. Особенность провайдера kubernetes: если у контейнера есть блок security_context, провайдер отправляет runAsNonRoot = false, и это перекрывает настройку пода — поэтому значение проверяется на уровне контейнера.

Как исправить: security_context { run_as_non_root = true } у пода и в каждом security_context контейнера.

Пример нарушения ([все примеры](../policies/examples/IAM-006.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_root" {
  metadata {
    name = "bad-root"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}
```

### IAM-007

**Корневая файловая система контейнера доступна на запись** · уровень: средний · [policies/rules/iam_007.rego](../policies/rules/iam_007.rego)

Без read_only_root_filesystem атакующий может менять бинарники внутри контейнера.

Как исправить: security_context { read_only_root_filesystem = true }, временные файлы — в emptyDir.

Пример нарушения ([все примеры](../policies/examples/IAM-007.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_rw_root" {
  metadata {
    name = "bad-rw-root"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}
```

### IAM-008

**Токен сервисного аккаунта монтируется в под** · уровень: средний · [policies/rules/iam_008.rego](../policies/rules/iam_008.rego)

Если приложению не нужен API Kubernetes, смонтированный токен — лишний ключ для атакующего.

Как исправить: automount_service_account_token = false в spec пода.

Пример нарушения ([все примеры](../policies/examples/IAM-008.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_token" {
  metadata {
    name = "bad-token"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}
```

### IAM-009

**Политика IAM AWS «*» на «*»** · уровень: критично · [policies/rules/iam_009.rego](../policies/rules/iam_009.rego)

Allow с Action "*" и Resource "*" равен правам администратора аккаунта.

Как исправить: Перечислите конкретные действия и ARN ресурсов.

Пример нарушения ([все примеры](../policies/examples/IAM-009.tf)):

```hcl
resource "aws_iam_policy" "bad_admin" {
  name   = "everything"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{ "Effect": "Allow", "Action": "*", "Resource": "*" }]
}
```

### IAM-010

**Широкая административная роль в облаке** · уровень: высокий · [policies/rules/iam_010.rego](../policies/rules/iam_010.rego)

Роли owner/editor GCP, Owner Azure на подписке или AdministratorAccess AWS выдают права на весь проект.

Как исправить: Выдайте узкие предопределённые или собственные роли.

Пример нарушения ([все примеры](../policies/examples/IAM-010.tf)):

```hcl
resource "google_project_iam_member" "bad_owner" {
  project = "shop"
  role    = "roles/owner"
  member  = "user:dev@shop.local"
}
```

## Журналирование

### LOG-001

**Бакет S3 без журнала доступа** · уровень: средний · [policies/rules/log_001.rego](../policies/rules/log_001.rego)

Без журнала доступа нельзя восстановить, кто и когда читал объекты.

Как исправить: Блок logging или ресурс aws_s3_bucket_logging для бакета.

Пример нарушения ([все примеры](../policies/examples/LOG-001.tf)):

```hcl
resource "aws_s3_bucket" "bad_no_logs" {
  bucket = "shop-files"
}
```

### LOG-002

**Журнал аудита облака неполный** · уровень: высокий · [policies/rules/log_002.rego](../policies/rules/log_002.rego)

CloudTrail только в одном регионе или без проверки целостности файлов журнала.

Как исправить: is_multi_region_trail = true, enable_log_file_validation = true.

Пример нарушения ([все примеры](../policies/examples/LOG-002.tf)):

```hcl
resource "aws_cloudtrail" "bad_single_region" {
  name           = "audit"
  s3_bucket_name = "shop-audit"
}
```

### LOG-003

**Управляемый Kubernetes без журналов control plane** · уровень: средний · [policies/rules/log_003.rego](../policies/rules/log_003.rego)

Журналы API-сервера и аудита кластера не собираются.

Как исправить: EKS: enabled_cluster_log_types с api и audit; GKE: logging_service не none; AKS: oms_agent.

Пример нарушения ([все примеры](../policies/examples/LOG-003.tf)):

```hcl
resource "aws_eks_cluster" "bad_no_logs" {
  name     = "shop"
  role_arn = "arn"
}
```

### LOG-004

**Балансировщик или сеть без журнала** · уровень: средний · [policies/rules/log_004.rego](../policies/rules/log_004.rego)

Нет журнала доступа балансировщика или журнала сетевых потоков подсети — разбор инцидента невозможен.

Как исправить: aws_lb: access_logs { enabled = true }; google_compute_subnetwork: log_config.

Пример нарушения ([все примеры](../policies/examples/LOG-004.tf)):

```hcl
resource "aws_lb" "bad_no_access_logs" {
  name = "shop"
}
```

## Ограничения ресурсов

### RES-001

**Контейнер без лимитов CPU и памяти** · уровень: высокий · [policies/rules/res_001.rego](../policies/rules/res_001.rego)

Контейнер без limits может занять весь узел и уронить соседние приложения.

Как исправить: resources { limits = { cpu = "500m", memory = "256Mi" } }.

Пример нарушения ([все примеры](../policies/examples/RES-001.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_no_limits" {
  metadata {
    name = "bad-no-limits"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}
```

### RES-002

**Контейнер без requests** · уровень: средний · [policies/rules/res_002.rego](../policies/rules/res_002.rego)

Без requests планировщик не знает, сколько ресурсов нужно поду, и квота пространства имён не работает.

Как исправить: resources { requests = { cpu = "100m", memory = "128Mi" } }.

Пример нарушения ([все примеры](../policies/examples/RES-002.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_no_requests" {
  metadata {
    name = "bad-no-requests"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}
```

### RES-003

**Пространство имён без ResourceQuota** · уровень: высокий · [policies/rules/res_003.rego](../policies/rules/res_003.rego)

Без квоты одно приложение может занять ресурсы всего кластера.

Как исправить: Создавайте пространство имён модулем app-namespace — он добавляет квоту.

Пример нарушения ([все примеры](../policies/examples/RES-003.tf)):

```hcl
resource "kubernetes_namespace_v1" "bad_ns" {
  metadata {
    name = "shop-dev"
  }
}
```

### RES-004

**Пространство имён без сетевой политики «запрещено всё»** · уровень: высокий · [policies/rules/res_004.rego](../policies/rules/res_004.rego)

Без default-deny любой под кластера может обращаться к подам этого пространства имён.

Как исправить: Создавайте пространство имён модулем app-namespace — он добавляет default-deny и явные разрешения.

Пример нарушения ([все примеры](../policies/examples/RES-004.tf)):

```hcl
resource "kubernetes_namespace_v1" "bad_ns" {
  metadata {
    name = "shop-dev"
  }
}
```

### RES-005

**Пространство имён без LimitRange** · уровень: средний · [policies/rules/res_005.rego](../policies/rules/res_005.rego)

LimitRange задаёт лимиты по умолчанию контейнерам, которые их не указали.

Как исправить: Создавайте пространство имён модулем app-namespace — он добавляет LimitRange.

Пример нарушения ([все примеры](../policies/examples/RES-005.tf)):

```hcl
resource "kubernetes_namespace_v1" "bad_ns" {
  metadata {
    name = "shop-dev"
  }
}
```

### RES-006

**Долгоживущий контейнер без проверок готовности и живости** · уровень: средний · [policies/rules/res_006.rego](../policies/rules/res_006.rego)

Без readiness_probe трафик идёт на неготовый под, без liveness_probe зависший процесс не перезапускается.

Как исправить: Добавьте readiness_probe и liveness_probe.

Пример нарушения ([все примеры](../policies/examples/RES-006.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_no_probes" {
  metadata {
    name = "bad-no-probes"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}
```

## Обязательные метки

### TAG-001

**Облачный ресурс без меток владельца, окружения и центра затрат** · уровень: высокий · [policies/rules/tag_001.rego](../policies/rules/tag_001.rego)

Ресурс без owner / environment / cost-center нельзя отнести к команде и бюджету.

Как исправить: Задайте tags (AWS, Azure) или labels (GCP); в AWS удобно через default_tags провайдера.

Пример нарушения ([все примеры](../policies/examples/TAG-001.tf)):

```hcl
resource "aws_instance" "bad_no_owner" {
  ami           = "ami-123"
  instance_type = "t3.micro"
  tags = {
    Name = "web"
  }
}
```

### TAG-002

**Объект Kubernetes без меток владельца, окружения и центра затрат** · уровень: высокий · [policies/rules/tag_002.rego](../policies/rules/tag_002.rego)

Пространства имён и рабочие нагрузки без owner / environment / cost-center нельзя отнести к команде и бюджету.

Как исправить: Задайте labels в metadata; модуль app-namespace проставляет их сам.

Пример нарушения ([все примеры](../policies/examples/TAG-002.tf)):

```hcl
resource "kubernetes_namespace_v1" "bad_ns" {
  metadata {
    name = "shop-dev"
  }
}
```

### TAG-003

**Недопустимое значение окружения** · уровень: средний · [policies/rules/tag_003.rego](../policies/rules/tag_003.rego)

Метка environment должна принимать одно из согласованных значений, иначе отчёты по затратам и политики окружений расходятся.

Как исправить: environment = dev | stage | prod (список в policies/config.yaml).

Пример нарушения ([все примеры](../policies/examples/TAG-003.tf)):

```hcl
resource "aws_instance" "bad_env" {
  ami           = "ami-123"
  instance_type = "t3.micro"
  tags = {
    environment = "production"
  }
}
```

## Именование

### NAME-001

**Имя объекта Kubernetes не по соглашению** · уровень: средний · [policies/rules/name_001.rego](../policies/rules/name_001.rego)

Имена пространств имён, нагрузок и сервисов — строчные латинские буквы, цифры и дефис, от 3 до 40 символов, начинаются с буквы.

Как исправить: Например: payments-api, shop-dev.

Пример нарушения ([все примеры](../policies/examples/NAME-001.tf)):

```hcl
resource "kubernetes_namespace_v1" "bad_ns" {
  metadata {
    name = "Shop_Dev"
  }
}
```

### NAME-002

**Имя пространства имён не заканчивается окружением** · уровень: средний · [policies/rules/name_002.rego](../policies/rules/name_002.rego)

Пространство имён приложения называется <система>-<окружение>, чтобы по имени было видно, где работает код.

Как исправить: Например: shop-dev, billing-prod.

Пример нарушения ([все примеры](../policies/examples/NAME-002.tf)):

```hcl
resource "kubernetes_namespace_v1" "bad_ns" {
  metadata {
    name = "shop"
    labels = { environment = "dev" }
  }
}
```

### NAME-003

**Имя бакета не по соглашению** · уровень: средний · [policies/rules/name_003.rego](../policies/rules/name_003.rego)

Имена бакетов — строчные буквы, цифры и дефис, без точек и подчёркиваний, от 3 до 63 символов.

Как исправить: Например: shop-dev-backups.

Пример нарушения ([все примеры](../policies/examples/NAME-003.tf)):

```hcl
resource "aws_s3_bucket" "bad_name" {
  bucket = "Shop.Backups_2026"
}
```

## Версии и источники модулей

### SRC-001

**Модуль из git или по ссылке без закреплённой версии** · уровень: критично · [policies/rules/src_001.rego](../policies/rules/src_001.rego)

Источник без ?ref=<тег или SHA> подтягивает то, что сейчас лежит в ветке по умолчанию: код может поменяться без ревью.

Как исправить: source = "git::https://github.com/org/repo.git//path?ref=v1.2.3" или полный SHA коммита.

### SRC-002

**Модуль из непроверенного источника** · уровень: критично · [policies/rules/src_002.rego](../policies/rules/src_002.rego)

Разрешены только локальные модули библиотеки, модули реестра из одобренных пространств имён и git-репозитории из списка.

Как исправить: Используйте модуль библиотеки или добавьте источник в policies/config.yaml через ревью команды платформы.

### SRC-003

**Модуль реестра без точной версии** · уровень: высокий · [policies/rules/src_003.rego](../policies/rules/src_003.rego)

Диапазон версий (~>, >=) или её отсутствие означает, что новая версия модуля придёт без ревью.

Как исправить: version = "5.8.1" и обновление через PR (например, Renovate).

### SRC-004

**Чарт Helm без закреплённой версии** · уровень: высокий · [policies/rules/src_004.rego](../policies/rules/src_004.rego)

Без точной version helm_release ставит последнюю версию чарта на момент применения: результат зависит от дня запуска.

Как исправить: version = "42.4.1".

Пример нарушения ([все примеры](../policies/examples/SRC-004.tf)):

```hcl
resource "helm_release" "bad_floating" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
}
```

### SRC-005

**Чарт Helm из репозитория по HTTP или вне списка** · уровень: критично · [policies/rules/src_005.rego](../policies/rules/src_005.rego)

Чарт по незашифрованному HTTP можно подменить по дороге; репозиторий вне списка не проходил проверку.

Как исправить: Репозиторий по https:// или oci:// из списка helm_repositories в policies/config.yaml.

Пример нарушения ([все примеры](../policies/examples/SRC-005.tf)):

```hcl
resource "helm_release" "bad_http_repo" {
  name       = "tool"
  repository = "http://charts.example.com"
  chart      = "tool"
  version    = "1.0.0"
}
```

### SRC-006

**Образ контейнера без версии или с тегом latest** · уровень: высокий · [policies/rules/src_006.rego](../policies/rules/src_006.rego)

latest и образ без тега меняются без ревью; откатиться на «вчерашнюю» версию невозможно.

Как исправить: Укажите точный тег (nginx:1.29.3) или дайджест (@sha256:...).

Пример нарушения ([все примеры](../policies/examples/SRC-006.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_latest" {
  metadata {
    name = "bad-latest"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:latest"
        }
      }
    }
  }
}
```

### SRC-007

**Образ из реестра вне списка** · уровень: средний · [policies/rules/src_007.rego](../policies/rules/src_007.rego)

Образы берутся только из одобренных реестров: их проверяет сканер и они доступны с площадки.

Как исправить: Перенесите образ в разрешённый реестр или добавьте реестр в image_registries (policies/config.yaml).

Пример нарушения ([все примеры](../policies/examples/SRC-007.tf)):

```hcl
resource "kubernetes_deployment_v1" "bad_unknown_registry" {
  metadata {
    name = "bad-unknown-registry"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "someuser/miner:1.0"
        }
      }
    }
  }
}
```

### SRC-008

**Провайдер без ограничения версии** · уровень: высокий · [policies/rules/src_008.rego](../policies/rules/src_008.rego)

Без version в required_providers новая мажорная версия провайдера может прийти при следующем init и сломать план.

Как исправить: required_providers { kubernetes = { source = "hashicorp/kubernetes", version = "~> 3.5" } } и .terraform.lock.hcl в репозитории.

Пример нарушения ([все примеры](../policies/examples/SRC-008.tf)):

```hcl
terraform {
  required_providers {
    bad_random = {
      source = "hashicorp/random"
    }
    good_kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.5"
    }
  }
}
```

### SRC-009

**Запрещённая (снятая с поддержки) версия движка** · уровень: высокий · [policies/rules/src_009.rego](../policies/rules/src_009.rego)

PostgreSQL ниже 14, MySQL ниже 8.0, Kubernetes ниже 1.32 больше не получают исправлений безопасности.

Как исправить: Поднимите версию; минимальные значения — в min_versions (policies/config.yaml).

Пример нарушения ([все примеры](../policies/examples/SRC-009.tf)):

```hcl
resource "aws_db_instance" "bad_old_pg" {
  engine         = "postgres"
  engine_version = "11.22"
}
```

### SRC-010

**Удалённый API Kubernetes или устаревший тип ресурса** · уровень: критично · [policies/rules/src_010.rego](../policies/rules/src_010.rego)

apiVersion, которого больше нет в кластере (extensions/v1beta1, policy/v1beta1 и т.п.), или ресурс провайдера без суффикса _v1, который не поддерживается.

Как исправить: Перейдите на актуальную apiVersion и ресурсы *_v1 провайдера kubernetes.

Пример нарушения ([все примеры](../policies/examples/SRC-010.tf)):

```hcl
resource "kubernetes_manifest" "bad_old_ingress" {
  manifest = {
    apiVersion = "extensions/v1beta1"
    kind       = "Ingress"
    metadata   = { name = "web", namespace = "shop-dev" }
  }
}
```

## Резервное копирование

### DB-001

**База данных без резервных копий** · уровень: высокий · [policies/rules/db_001.rego](../policies/rules/db_001.rego)

Резервное копирование выключено или хранится меньше 7 дней.

Как исправить: AWS: backup_retention_period >= 7; GCP: backup_configuration.enabled; модуль postgres-cnpg: backup.enabled = true.

Пример нарушения ([все примеры](../policies/examples/DB-001.tf)):

```hcl
resource "aws_db_instance" "bad_no_backups" {
  engine                  = "postgres"
  backup_retention_period = 0
}
```

### DB-002

**База данных без защиты от удаления** · уровень: средний · [policies/rules/db_002.rego](../policies/rules/db_002.rego)

Ошибочный destroy или замена ресурса удалит базу вместе с данными.

Как исправить: deletion_protection = true (AWS, GCP).

Пример нарушения ([все примеры](../policies/examples/DB-002.tf)):

```hcl
resource "aws_db_instance" "bad_unprotected" {
  engine              = "postgres"
  deletion_protection = false
}
```

## Исключения

### EXC-001

**Исключение оформлено без обоснования, владельца или срока** · уровень: критично · [policies/rules/exc_001.rego](../policies/rules/exc_001.rego)

Каждое исключение в policies/exceptions.yaml содержит правило, ресурс, обоснование (от 15 символов), владельца и дату окончания не дальше 180 дней. Иначе оно не действует и само блокирует слияние.

Как исправить: Дополните запись: reason, owner, expires: YYYY-MM-DD.

Пример нарушения ([все примеры](../policies/examples/EXC-001.tf)):

```yaml
exceptions:
  - rule: PUB-002
    resource: kubernetes_service_v1.bad_no_reason
    reason: "надо"
    owner: team-shop
    expires: "+60d"
```

### EXC-002

**Просроченное исключение** · уровень: средний · [policies/rules/exc_002.rego](../policies/rules/exc_002.rego)

Срок исключения истёк: оно больше не действует, нарушение снова проверяется. Запись нужно удалить или продлить с новым обоснованием.

Как исправить: Исправьте нарушение и удалите запись или продлите expires через ревью.

Пример нарушения ([все примеры](../policies/examples/EXC-002.tf)):

```yaml
exceptions:
  - rule: PUB-002
    resource: kubernetes_service_v1.bad_expired
    reason: "Временный NodePort для нагрузочного теста, задача OPS-101"
    owner: team-shop
    expires: "-30d"
```
