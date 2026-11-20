variable "name" {
  description = "Имя кластера PostgreSQL."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,38}[a-z0-9]$", var.name))
    error_message = "Имя: строчные буквы, цифры и дефис, 3–40 символов."
  }
}

variable "namespace" {
  description = "Пространство имён приложения (обычно выход модуля app-namespace)."
  type        = string
}

variable "labels" {
  description = "Метки кластера и его подов (owner, environment, cost-center)."
  type        = map(string)
  default     = {}
}

variable "instances" {
  description = "Число экземпляров: 1 — без реплик, 2+ — с автоматическим переключением."
  type        = number
  default     = 2
}

variable "image" {
  description = "Образ PostgreSQL CloudNativePG."
  type        = string
  default     = "ghcr.io/cloudnative-pg/postgresql:17.6"

  validation {
    condition     = can(regex(":(1[4-9]|[2-9][0-9])([.]|-|$)", var.image)) || can(regex("@sha256:", var.image))
    error_message = "Поддерживаются PostgreSQL 14 и новее, образ с точным тегом или дайджестом."
  }
}

variable "storage_size" {
  description = "Размер тома каждого экземпляра."
  type        = string
  default     = "1Gi"
}

variable "storage_class" {
  description = "StorageClass; пустая строка — класс по умолчанию."
  type        = string
  default     = ""
}

variable "database" {
  description = "Имя базы приложения."
  type        = string
  default     = "app"
}

variable "database_owner" {
  description = "Владелец базы; пароль оператор кладёт в секрет <name>-app."
  type        = string
  default     = "app"
}

variable "resources" {
  description = "Запросы и лимиты контейнера PostgreSQL."
  type = object({
    requests = optional(map(string), { cpu = "100m", memory = "256Mi" })
    limits   = optional(map(string), { cpu = "1", memory = "512Mi" })
  })
  default = {}
}

variable "postgresql_parameters" {
  description = "Параметры postgresql.conf."
  type        = map(string)
  default     = {}
}

variable "pod_monitor" {
  description = "Создать PodMonitor для Prometheus (нужны CRD prometheus-operator)."
  type        = bool
  default     = false
}

variable "backup" {
  description = "Резервное копирование в S3-совместимое хранилище (MinIO)."
  type = object({
    enabled        = optional(bool, true)
    endpoint       = optional(string, "")
    bucket         = optional(string, "")
    path           = optional(string, "cnpg")
    retention      = optional(string, "14d")
    schedule       = optional(string, "0 0 2 * * *")
    immediate      = optional(bool, true)
    s3_secret_name = optional(string, "")
  })
  default = {}

  validation {
    condition     = !var.backup.enabled || (var.backup.endpoint != "" && var.backup.bucket != "")
    error_message = "При включённом резервном копировании нужны backup.endpoint и backup.bucket."
  }
  validation {
    condition     = can(regex("^[0-9]+[dwm]$", var.backup.retention))
    error_message = "retention в формате 14d, 4w или 3m."
  }
}

variable "s3_access_key" {
  description = "Ключ доступа к хранилищу (write-only, в состояние не попадает). Не нужен, если задан backup.s3_secret_name."
  type        = string
  default     = null
  sensitive   = true
  ephemeral   = true
}

variable "s3_secret_key" {
  description = "Секретный ключ хранилища (write-only, в состояние не попадает)."
  type        = string
  default     = null
  sensitive   = true
  ephemeral   = true
}

variable "s3_credentials_revision" {
  description = "Увеличьте, чтобы перезаписать ключи в секрете после ротации."
  type        = number
  default     = 1
}

variable "restore" {
  description = "Создать кластер восстановлением из резервной копии другого кластера."
  type = object({
    enabled        = optional(bool, false)
    origin_cluster = optional(string, "")
    origin_store   = optional(string, "")
  })
  default = {}

  validation {
    condition     = !var.restore.enabled || var.restore.origin_cluster != ""
    error_message = "Для восстановления укажите restore.origin_cluster."
  }
}

variable "install_operator" {
  description = "Установить оператор CloudNativePG и плагин barman-cloud (один раз на кластер Kubernetes)."
  type        = bool
  default     = false
}

variable "operator_namespace" {
  description = "Пространство имён оператора."
  type        = string
  default     = "cnpg-system"
}

variable "operator_chart_version" {
  description = "Версия чарта cloudnative-pg."
  type        = string
  default     = "0.29.2"
}

variable "barman_plugin_chart_version" {
  description = "Версия чарта plugin-barman-cloud."
  type        = string
  default     = "0.9.0"
}

variable "timeout" {
  description = "Сколько секунд ждать готовности кластера."
  type        = number
  default     = 900
}
