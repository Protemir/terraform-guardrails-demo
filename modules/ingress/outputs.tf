output "ingress_class_name" {
  description = "Имя IngressClass для объектов Ingress."
  value       = "traefik"
}

output "cluster_issuer" {
  description = "ClusterIssuer для аннотации cert-manager.io/cluster-issuer."
  value       = var.acme_email != "" ? "letsencrypt" : var.stand_ca_issuer_name
}

output "namespace" {
  description = "Пространство имён ingress-контроллера (для сетевых политик приложений)."
  value       = helm_release.traefik.namespace
}

output "versions" {
  description = "Установленные версии чартов."
  value = {
    traefik      = helm_release.traefik.version
    cert_manager = helm_release.cert_manager.version
  }
}
