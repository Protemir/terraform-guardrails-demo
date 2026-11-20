locals {
  store_name = "${var.name}-store"
  s3_secret  = var.backup.enabled ? (var.backup.s3_secret_name != "" ? var.backup.s3_secret_name : "${var.name}-s3") : ""

  cluster_values = {
    name          = var.name
    instances     = var.instances
    imageName     = var.image
    storageSize   = var.storage_size
    storageClass  = var.storage_class
    database      = var.database
    owner         = var.database_owner
    labels        = var.labels
    resources     = var.resources
    postgresql    = { parameters = var.postgresql_parameters }
    podMonitor    = var.pod_monitor
    plugin        = "barman-cloud.cloudnative-pg.io"
    backup = {
      enabled         = var.backup.enabled
      storeName       = local.store_name
      destinationPath = "s3://${var.backup.bucket}/${var.backup.path}"
      endpointURL     = var.backup.endpoint
      secretName      = local.s3_secret
      retention       = var.backup.retention
      schedule        = var.backup.schedule
      immediate       = var.backup.immediate
    }
    restore = {
      enabled    = var.restore.enabled
      originName = var.restore.origin_cluster
      originStore = var.restore.origin_store != "" ? var.restore.origin_store : "${var.restore.origin_cluster}-store"
    }
  }
}

# ---------- оператор и плагин резервного копирования (один раз на кластер Kubernetes) ----------

resource "helm_release" "operator" {
  count = var.install_operator ? 1 : 0

  name             = "cnpg"
  namespace        = var.operator_namespace
  create_namespace = true
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  version          = var.operator_chart_version
  atomic           = true
  timeout          = 600

  values = [yamlencode({
    resources = {
      requests = { cpu = "100m", memory = "128Mi" }
      limits   = { cpu = "500m", memory = "512Mi" }
    }
  })]
}

# barman-cloud: резервные копии и WAL в S3-совместимое хранилище (MinIO).
# Требует cert-manager (модуль ingress).
resource "helm_release" "barman_plugin" {
  count = var.install_operator ? 1 : 0

  name       = "barman-cloud"
  namespace  = var.operator_namespace
  repository = "https://cloudnative-pg.github.io/charts"
  chart      = "plugin-barman-cloud"
  version    = var.barman_plugin_chart_version
  atomic     = true
  timeout    = 600

  depends_on = [helm_release.operator]
}

# ---------- доступ к хранилищу резервных копий ----------
# Ключи передаются write-only атрибутом: не попадают ни в план, ни в состояние Terraform.
resource "kubernetes_secret_v1" "s3" {
  count = var.backup.enabled && var.backup.s3_secret_name == "" ? 1 : 0

  metadata {
    name      = local.s3_secret
    namespace = var.namespace
    labels    = var.labels
  }

  data_wo = {
    ACCESS_KEY_ID     = var.s3_access_key
    ACCESS_SECRET_KEY = var.s3_secret_key
  }
  data_wo_revision = var.s3_credentials_revision
}

# ---------- кластер PostgreSQL, хранилище копий и расписание ----------

resource "helm_release" "cluster" {
  name      = var.name
  namespace = var.namespace
  chart     = "${path.module}/charts/cnpg-cluster"
  atomic    = true
  wait      = true
  timeout   = var.timeout

  values = [yamlencode(local.cluster_values)]

  depends_on = [helm_release.operator, helm_release.barman_plugin, kubernetes_secret_v1.s3]
}
