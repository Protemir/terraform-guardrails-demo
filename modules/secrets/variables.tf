variable "install_controller" {
  description = "Установить контроллер Sealed Secrets (один раз на кластер)."
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Пространство имён контроллера; kube-system — значение по умолчанию для kubeseal."
  type        = string
  default     = "kube-system"
}

variable "chart_version" {
  description = "Версия чарта sealed-secrets."
  type        = string
  default     = "2.22.0"
}

variable "key_renew_period" {
  description = "Период ротации ключа шифрования контроллера."
  type        = string
  default     = "720h"
}

variable "service_monitor" {
  description = "Создать ServiceMonitor контроллера (нужны CRD prometheus-operator)."
  type        = bool
  default     = false
}

variable "sealed_secrets" {
  description = "Зашифрованные секреты: имя => пространство имён и шифртекст из kubeseal."
  type = map(object({
    namespace      = string
    encrypted_data = map(string)
    type           = optional(string, "Opaque")
    labels         = optional(map(string), {})
    scope          = optional(string, "strict")
  }))
  default = {}

  validation {
    condition     = alltrue([for s in values(var.sealed_secrets) : contains(["strict", "namespace-wide", "cluster-wide"], s.scope)])
    error_message = "scope: strict, namespace-wide или cluster-wide."
  }
  validation {
    condition     = alltrue([for s in values(var.sealed_secrets) : alltrue([for v in values(s.encrypted_data) : length(v) >= 64])])
    error_message = "encrypted_data должен содержать шифртекст kubeseal, а не открытое значение."
  }
}
