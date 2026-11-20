# Восстановление базы shop-db из резервной копии в MinIO в новый кластер shop-db-restore.
# Запускается из tests/e2e/backup-restore.sh; состояние локальное, после проверки — destroy.
terraform {
  required_version = ">= 1.11.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.5"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3"
    }
  }
}

variable "kubeconfig" {
  description = "Путь к kubeconfig стенда."
  type        = string
}

provider "kubernetes" {
  config_path    = var.kubeconfig
  config_context = "kind-stand"
}

provider "helm" {
  kubernetes = {
    config_path    = var.kubeconfig
    config_context = "kind-stand"
  }
}

module "restore" {
  source = "../../../modules/postgres-cnpg"

  name      = "shop-db-restore"
  namespace = "shop-dev"
  labels    = { owner = "team-shop", environment = "dev", "cost-center" = "cc-1042" }
  instances = 1

  backup  = { enabled = false }
  restore = { enabled = true, origin_cluster = "shop-db" }
}
