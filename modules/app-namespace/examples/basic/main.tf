terraform {
  required_version = ">= 1.11.0"

  required_providers {
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

module "shop_ns" {
  source = "../.."

  name                    = "shop-dev"
  environment             = "dev"
  owner                   = "team-shop"
  cost_center             = "cc-1042"
  ingress_from_namespaces = ["traefik", "monitoring"]
  developer_groups        = ["shop-developers"]
  viewer_groups           = ["support"]

  quota = {
    requests_cpu    = "4"
    requests_memory = "8Gi"
  }
}

output "namespace" {
  description = "Созданное пространство имён."
  value       = module.shop_ns.name
}
