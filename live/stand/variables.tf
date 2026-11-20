variable "kubeconfig" {
  description = "Путь к kubeconfig стенда."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Контекст kubeconfig (kind создаёт kind-<имя кластера>)."
  type        = string
  default     = "kind-stand"
}

variable "backup_endpoint" {
  description = "Адрес MinIO изнутри кластера (контейнер minio в сети kind)."
  type        = string
  default     = "http://minio:9000"
}

variable "backup_bucket" {
  description = "Бакет MinIO для резервных копий PostgreSQL."
  type        = string
  default     = "backups"
}

variable "s3_access_key" {
  description = "Ключ MinIO для резервных копий (из секретов CI, в состояние не попадает)."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "s3_secret_key" {
  description = "Секретный ключ MinIO (из секретов CI, в состояние не попадает)."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "egress_cidrs" {
  description = "Сеть docker kind, где живёт MinIO: туда разрешён исходящий трафик базы."
  type        = list(string)
  default     = ["172.18.0.0/16"]
}

variable "monitoring_stack" {
  description = "Ставить kube-prometheus-stack (на слабой машине можно выключить)."
  type        = bool
  default     = true
}

variable "db_instances" {
  description = "Число экземпляров PostgreSQL на стенде."
  type        = number
  default     = 1
}
