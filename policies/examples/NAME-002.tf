# Пример для правила NAME-002: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_namespace_v1" "bad_ns" {
  metadata {
    name = "shop"
    labels = { environment = "dev" }
  }
}

resource "kubernetes_namespace_v1" "good_ns" {
  metadata {
    name = "shop-dev"
    labels = { environment = "dev" }
  }
}
