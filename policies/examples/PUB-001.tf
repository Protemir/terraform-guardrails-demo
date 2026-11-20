# Пример для правила PUB-001: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_service_v1" "bad_public_lb" {
  metadata {
    name = "web"
  }
  spec {
    type = "LoadBalancer"
  }
}

resource "kubernetes_service_v1" "good_internal_lb" {
  metadata {
    name        = "web-internal"
    annotations = { "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internal" }
  }
  spec {
    type = "LoadBalancer"
  }
}

resource "kubernetes_service_v1" "good_cluster_ip" {
  metadata {
    name = "web"
  }
  spec {
    type = "ClusterIP"
  }
}
