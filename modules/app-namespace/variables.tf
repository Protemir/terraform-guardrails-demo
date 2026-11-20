variable "name" {
  description = "Имя пространства имён: <система>-<окружение>, например shop-dev."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,38}[a-z0-9]$", var.name))
    error_message = "Имя: строчные латинские буквы, цифры и дефис, 3–40 символов."
  }
}

variable "environment" {
  description = "Окружение: dev, stage или prod."
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment должен быть dev, stage или prod."
  }
}

variable "owner" {
  description = "Команда-владелец (метка owner)."
  type        = string
}

variable "cost_center" {
  description = "Центр затрат (метка cost-center)."
  type        = string
}

variable "labels" {
  description = "Дополнительные метки для всех объектов модуля."
  type        = map(string)
  default     = {}
}

variable "pod_security_level" {
  description = "Уровень Pod Security Admission: restricted или baseline."
  type        = string
  default     = "restricted"

  validation {
    condition     = contains(["restricted", "baseline"], var.pod_security_level)
    error_message = "Допустимо restricted или baseline; privileged модуль не создаёт."
  }
}

variable "quota" {
  description = "Квота пространства имён."
  type = object({
    requests_cpu    = optional(string, "2")
    requests_memory = optional(string, "4Gi")
    limits_cpu      = optional(string, "4")
    limits_memory   = optional(string, "8Gi")
    storage         = optional(string, "20Gi")
    pods            = optional(number, 30)
    pvcs            = optional(number, 10)
  })
  default = {}
}

variable "container_defaults" {
  description = "LimitRange: значения по умолчанию и максимум для контейнера."
  type = object({
    request_cpu    = optional(string, "50m")
    request_memory = optional(string, "64Mi")
    limit_cpu      = optional(string, "500m")
    limit_memory   = optional(string, "256Mi")
    max_cpu        = optional(string, "2")
    max_memory     = optional(string, "2Gi")
  })
  default = {}
}

variable "ingress_from_namespaces" {
  description = "Пространства имён, из которых разрешён входящий трафик (ingress-контроллер, мониторинг, операторы)."
  type        = list(string)
  default     = []
}

variable "egress_cidrs" {
  description = "Внешние адреса, куда разрешён исходящий трафик (например, объектное хранилище для резервных копий)."
  type        = list(string)
  default     = []
}

variable "allow_kube_api" {
  description = "Разрешить подам обращаться к API Kubernetes (порты 443/6443)."
  type        = bool
  default     = false
}

variable "developer_groups" {
  description = "Группы с ролью developer (чтение, перезапуск подов, масштабирование)."
  type        = list(string)
  default     = []
}

variable "viewer_groups" {
  description = "Группы с ролью viewer (только чтение, без секретов)."
  type        = list(string)
  default     = []
}
