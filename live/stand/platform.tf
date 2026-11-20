# Платформа стенда: то, что ставится один раз на кластер.

module "ingress" {
  source = "../../modules/ingress"

  service_type = "NodePort" # kind пробрасывает 30080/30443 на localhost
  replicas     = 1
}

module "secrets" {
  source = "../../modules/secrets"
}

module "monitoring" {
  source = "../../modules/ns-monitoring"
  count  = var.monitoring_stack ? 1 : 0

  install_stack = true
  namespace     = "monitoring"
  labels        = local.platform_labels
  dashboard     = false
}

locals {
  platform_labels = {
    owner         = "platform"
    environment   = "dev"
    "cost-center" = "cc-0001"
  }
}
