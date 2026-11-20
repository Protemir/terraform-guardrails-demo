# Пример для правила RES-005: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_namespace_v1" "bad_ns" {
  metadata {
    name = "shop-dev"
  }
}

resource "kubernetes_namespace_v1" "good_ns" {
  metadata {
    name = "billing-dev"
  }
}

resource "kubernetes_limit_range_v1" "good_limits" {
  metadata {
    name      = "defaults"
    namespace = "billing-dev"
  }
  spec {
    limit {
      type            = "Container"
      default         = { cpu = "500m", memory = "256Mi" }
      default_request = { cpu = "100m", memory = "128Mi" }
    }
  }
}
