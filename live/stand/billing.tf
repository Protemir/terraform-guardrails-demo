# Новое приложение billing: пространство имён, база и мониторинг из модулей библиотеки.
module "billing_ns" {
  source = "../../modules/app-namespace"

  name                    = "billing-dev"
  environment             = "dev"
  owner                   = "team-billing"
  cost_center             = "cc-2010"
  ingress_from_namespaces = [module.ingress.namespace, "monitoring", "cnpg-system"]
  egress_cidrs            = var.egress_cidrs
  allow_kube_api          = true
  developer_groups        = ["billing-developers"]

  quota = {
    requests_cpu    = "1"
    requests_memory = "2Gi"
  }
}

module "billing_db" {
  source = "../../modules/postgres-cnpg"

  name      = "billing-db"
  namespace = module.billing_ns.name
  labels    = module.billing_ns.labels
  instances = var.db_instances

  backup = {
    endpoint = var.backup_endpoint
    bucket   = var.backup_bucket
    path     = "billing-dev"
  }
  s3_access_key = var.s3_access_key
  s3_secret_key = var.s3_secret_key

  depends_on = [module.shop_db] # оператор ставит модуль shop_db
}

module "billing_monitoring" {
  source = "../../modules/ns-monitoring"
  count  = var.monitoring_stack ? 1 : 0

  namespace = module.billing_ns.name
  labels    = module.billing_ns.labels

  depends_on = [module.monitoring]
}
