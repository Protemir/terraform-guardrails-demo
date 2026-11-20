terraform {
  required_version = ">= 1.11.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "kind-stand"
  }
}

module "monitoring_stack" {
  source = "../.."

  install_stack = true
  namespace     = "monitoring"
  dashboard     = false
}

module "shop_monitoring" {
  source = "../.."

  namespace = "shop-dev"
  labels    = { owner = "team-shop", environment = "dev", "cost-center" = "cc-1042" }

  depends_on = [module.monitoring_stack]
}

output "alerts" {
  description = "Оповещения пространства имён."
  value       = module.shop_monitoring.alert_names
}
