variable "namespace" {
  description = "Пространство имён приложения, которое подключаем к мониторингу."
  type        = string
}

variable "labels" {
  description = "Метки объектов (owner, environment, cost-center); owner попадает в оповещения для маршрутизации."
  type        = map(string)
  default     = {}
}

variable "service_selector" {
  description = "Метки сервисов, с которых собирать метрики."
  type        = map(string)
  default     = { metrics = "enabled" }
}

variable "metrics_port" {
  description = "Имя порта сервиса с метриками."
  type        = string
  default     = "metrics"
}

variable "metrics_path" {
  description = "Путь метрик."
  type        = string
  default     = "/metrics"
}

variable "alerts" {
  description = "Пороги оповещений пространства имён."
  type = object({
    restarts_per_hour  = optional(number, 3)
    quota_usage_ratio  = optional(number, 0.9)
    not_ready_minutes  = optional(number, 10)
    cpu_throttle_ratio = optional(number, 0.5)
    severity           = optional(string, "warning")
  })
  default = {}

  validation {
    condition     = var.alerts.quota_usage_ratio > 0 && var.alerts.quota_usage_ratio <= 1
    error_message = "quota_usage_ratio — доля от 0 до 1."
  }
}

variable "dashboard" {
  description = "Создать панель Grafana для пространства имён."
  type        = bool
  default     = true
}

variable "dashboard_folder" {
  description = "Папка Grafana для панели."
  type        = string
  default     = "Приложения"
}

variable "install_stack" {
  description = "Установить kube-prometheus-stack (один раз на кластер)."
  type        = bool
  default     = false
}

variable "monitoring_namespace" {
  description = "Пространство имён стека мониторинга."
  type        = string
  default     = "monitoring"
}

variable "stack_chart_version" {
  description = "Версия чарта kube-prometheus-stack."
  type        = string
  default     = "93.5.0"
}

variable "alertmanager_enabled" {
  description = "Включить Alertmanager в стеке."
  type        = bool
  default     = false
}

variable "retention" {
  description = "Срок хранения метрик Prometheus."
  type        = string
  default     = "7d"
}
