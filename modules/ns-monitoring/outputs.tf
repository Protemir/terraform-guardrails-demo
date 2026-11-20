output "alert_names" {
  description = "Оповещения, которые получает пространство имён."
  value       = ["NamespacePodRestarting", "NamespaceQuotaNearLimit", "NamespacePodNotReady", "NamespaceCpuThrottling"]
}

output "monitoring_namespace" {
  description = "Пространство имён Prometheus и Grafana (для сетевой политики приложения)."
  value       = var.monitoring_namespace
}
