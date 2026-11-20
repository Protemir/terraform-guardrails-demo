resource "helm_release" "controller" {
  count = var.install_controller ? 1 : 0

  name             = "sealed-secrets"
  namespace        = var.namespace
  create_namespace = var.namespace != "kube-system"
  repository       = "https://bitnami.github.io/sealed-secrets"
  chart            = "sealed-secrets"
  version          = var.chart_version
  atomic           = true
  timeout          = 300

  values = [yamlencode({
    # Имя по умолчанию для kubeseal: kubeseal находит контроллер без флагов.
    fullnameOverride = "sealed-secrets-controller"
    keyrenewperiod   = var.key_renew_period
    resources = {
      requests = { cpu = "50m", memory = "64Mi" }
      limits   = { cpu = "250m", memory = "256Mi" }
    }
    metrics = { serviceMonitor = { enabled = var.service_monitor } }
  })]
}

# Зашифрованные секреты приложений. В репозитории лежит только шифртекст (kubeseal --raw),
# расшифровать его может только контроллер в кластере.
resource "helm_release" "sealed" {
  for_each = var.sealed_secrets

  name      = "sealed-${each.key}"
  namespace = each.value.namespace
  chart     = "${path.module}/charts/sealed-secrets"
  atomic    = true

  values = [yamlencode({
    name          = each.key
    type          = each.value.type
    labels        = each.value.labels
    encryptedData = each.value.encrypted_data
    scope         = each.value.scope
  })]

  depends_on = [helm_release.controller]
}
