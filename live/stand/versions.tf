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

  # Состояние — в MinIO стенда, блокировка — lock-файлом в том же бакете (use_lockfile).
  # Параметры: stand/backend.hcl, ключи — переменные AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY.
  backend "s3" {}
}

provider "kubernetes" {
  config_path    = var.kubeconfig
  config_context = var.kube_context
}

provider "helm" {
  kubernetes = {
    config_path    = var.kubeconfig
    config_context = var.kube_context
  }
}
