locals {
  traefik_values = {
    deployment = { replicas = var.replicas }
    ingressClass = {
      enabled        = true
      isDefaultClass = true
      name           = "traefik"
    }
    service = { spec = { type = var.service_type } }
    ports = {
      web = merge(
        var.service_type == "NodePort" ? { nodePort = var.node_ports.http } : {},
        # Всё по HTTP перенаправляется на HTTPS.
        { http = { redirections = { entryPoint = { to = "websecure", scheme = "https", permanent = true } } } },
      )
      websecure = var.service_type == "NodePort" ? { nodePort = var.node_ports.https } : {}
    }
    resources = {
      requests = { cpu = "100m", memory = "64Mi" }
      limits   = { cpu = "500m", memory = "256Mi" }
    }
    metrics = {
      prometheus = { serviceMonitor = { enabled = var.service_monitor } }
    }
    podDisruptionBudget = { enabled = var.replicas > 1, minAvailable = 1 }
  }
}

resource "helm_release" "traefik" {
  name             = "traefik"
  namespace        = var.namespace
  create_namespace = true
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = var.traefik_chart_version
  atomic           = true
  timeout          = 300

  values = [yamlencode(local.traefik_values)]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = var.cert_manager_namespace
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  atomic           = true
  timeout          = 600

  values = [yamlencode({
    crds = { enabled = true, keep = true }
    resources = {
      requests = { cpu = "50m", memory = "64Mi" }
      limits   = { cpu = "250m", memory = "256Mi" }
    }
    prometheus = { servicemonitor = { enabled = var.service_monitor } }
  })]
}

# Эмитенты сертификатов: собственный CA стенда и (по желанию) Let's Encrypt.
# Собраны в локальный чарт, чтобы план строился до установки CRD cert-manager.
resource "helm_release" "issuers" {
  name      = "cluster-issuers"
  namespace = var.cert_manager_namespace
  chart     = "${path.module}/charts/cluster-issuers"
  atomic    = true

  values = [yamlencode({
    standCa = { enabled = var.stand_ca_enabled, name = var.stand_ca_issuer_name }
    acme = {
      enabled = var.acme_email != ""
      email   = var.acme_email
      server  = var.acme_server
    }
    ingressClass = "traefik"
  })]

  depends_on = [helm_release.cert_manager]
}
