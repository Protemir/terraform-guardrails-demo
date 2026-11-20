terraform {
  required_version = ">= 1.11.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.5"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-stand"
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "kind-stand"
  }
}

variable "s3_access_key" {
  description = "Ключ MinIO."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "s3_secret_key" {
  description = "Секретный ключ MinIO."
  type        = string
  sensitive   = true
  ephemeral   = true
}

module "db" {
  source = "../.."

  name             = "shop-db"
  namespace        = "shop-dev"
  labels           = { owner = "team-shop", environment = "dev", "cost-center" = "cc-1042" }
  install_operator = true

  backup = {
    endpoint = "http://minio:9000"
    bucket   = "backups"
    path     = "shop-dev"
  }
  s3_access_key = var.s3_access_key
  s3_secret_key = var.s3_secret_key
}

output "rw_host" {
  description = "Адрес основного экземпляра."
  value       = module.db.rw_host
}
