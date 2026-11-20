output "name" {
  description = "Имя созданного пространства имён."
  value       = kubernetes_namespace_v1.this.metadata[0].name
}

output "labels" {
  description = "Метки, которые модуль проставил объектам (owner, environment, cost-center и служебные)."
  value       = local.labels
}

output "network_policies" {
  description = "Созданные сетевые политики."
  value = concat(
    [kubernetes_network_policy_v1.default_deny.metadata[0].name, kubernetes_network_policy_v1.same_namespace.metadata[0].name, kubernetes_network_policy_v1.dns.metadata[0].name],
    [for p in kubernetes_network_policy_v1.from_namespaces : p.metadata[0].name],
    [for p in kubernetes_network_policy_v1.egress_cidrs : p.metadata[0].name],
    [for p in kubernetes_network_policy_v1.kube_api : p.metadata[0].name],
  )
}
