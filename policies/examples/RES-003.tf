# Пример для правила RES-003: ресурсы bad_* нарушают правило, good_* — нет.

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

resource "kubernetes_resource_quota_v1" "good_quota" {
  metadata {
    name      = "quota"
    namespace = kubernetes_namespace_v1.good_ns.metadata[0].name
  }
  spec {
    hard = { "requests.cpu" = "2", "requests.memory" = "4Gi" }
  }
}
