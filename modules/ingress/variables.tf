variable "namespace" {
  description = "Пространство имён ingress-контроллера Traefik."
  type        = string
  default     = "traefik"
}

variable "cert_manager_namespace" {
  description = "Пространство имён cert-manager."
  type        = string
  default     = "cert-manager"
}

variable "traefik_chart_version" {
  description = "Версия чарта traefik/traefik."
  type        = string
  default     = "42.4.1"
}

variable "cert_manager_chart_version" {
  description = "Версия чарта jetstack/cert-manager."
  type        = string
  default     = "v1.21.3"
}

variable "service_type" {
  description = "Тип сервиса Traefik: LoadBalancer в облаке, NodePort на локальном стенде (kind)."
  type        = string
  default     = "LoadBalancer"

  validation {
    condition     = contains(["LoadBalancer", "NodePort", "ClusterIP"], var.service_type)
    error_message = "service_type: LoadBalancer, NodePort или ClusterIP."
  }
}

variable "node_ports" {
  description = "Порты узла для NodePort (на kind пробрасываются на localhost)."
  type = object({
    http  = optional(number, 30080)
    https = optional(number, 30443)
  })
  default = {}
}

variable "replicas" {
  description = "Число реплик Traefik; при 2+ включается PodDisruptionBudget."
  type        = number
  default     = 2
}

variable "service_monitor" {
  description = "Создавать ServiceMonitor для Prometheus (нужны CRD prometheus-operator)."
  type        = bool
  default     = false
}

variable "stand_ca_enabled" {
  description = "Создать собственный CA и ClusterIssuer на его основе (локальный стенд, внутренние сервисы)."
  type        = bool
  default     = true
}

variable "stand_ca_issuer_name" {
  description = "Имя ClusterIssuer собственного CA."
  type        = string
  default     = "stand-ca"
}

variable "acme_email" {
  description = "Почта для Let's Encrypt; пустая строка — ACME-эмитент не создаётся."
  type        = string
  default     = ""
}

variable "acme_server" {
  description = "Адрес ACME-сервера."
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}
