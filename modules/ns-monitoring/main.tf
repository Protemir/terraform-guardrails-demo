# Prometheus Operator + Grafana. Ставится один раз на кластер (install_stack = true).
resource "helm_release" "stack" {
  count = var.install_stack ? 1 : 0

  name             = "kube-prometheus-stack"
  namespace        = var.monitoring_namespace
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.stack_chart_version
  atomic           = true
  timeout          = 900

  values = [yamlencode({
    alertmanager = { enabled = var.alertmanager_enabled }
    grafana = {
      adminPassword = null
      sidecar = {
        dashboards = { enabled = true, label = "grafana_dashboard", labelValue = "1", searchNamespace = "ALL", folderAnnotation = "grafana_folder", provider = { foldersFromFilesStructure = true } }
      }
      resources = {
        requests = { cpu = "50m", memory = "128Mi" }
        limits   = { cpu = "500m", memory = "512Mi" }
      }
    }
    prometheus = {
      prometheusSpec = {
        # Подхватывать ServiceMonitor/PodMonitor/PrometheusRule из всех пространств имён.
        serviceMonitorSelectorNilUsesHelmValues = false
        podMonitorSelectorNilUsesHelmValues     = false
        ruleSelectorNilUsesHelmValues           = false
        retention                               = var.retention
        resources = {
          requests = { cpu = "100m", memory = "512Mi" }
          limits   = { cpu = "1", memory = "1536Mi" }
        }
      }
    }
    # На kind control plane недоступен для сбора — отключаем лишние цели.
    kubeEtcd              = { enabled = false }
    kubeControllerManager = { enabled = false }
    kubeScheduler         = { enabled = false }
    kubeProxy             = { enabled = false }
  })]
}

# Подключение пространства имён: сбор метрик, оповещения и панель Grafana.
resource "helm_release" "namespace" {
  name      = "monitoring-${var.namespace}"
  namespace = var.namespace
  chart     = "${path.module}/charts/ns-monitoring"
  atomic    = true

  values = [yamlencode({
    namespace       = var.namespace
    labels          = var.labels
    serviceSelector = var.service_selector
    metricsPort     = var.metrics_port
    metricsPath     = var.metrics_path
    alerts = {
      restartsPerHour  = var.alerts.restarts_per_hour
      quotaUsageRatio  = var.alerts.quota_usage_ratio
      notReadyMinutes  = var.alerts.not_ready_minutes
      cpuThrottleRatio = var.alerts.cpu_throttle_ratio
      severity         = var.alerts.severity
    }
    dashboard = { enabled = var.dashboard, folder = var.dashboard_folder }
  })]

  depends_on = [helm_release.stack]
}
