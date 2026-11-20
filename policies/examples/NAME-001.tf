# Пример для правила NAME-001: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_namespace_v1" "bad_ns" {
  metadata {
    name = "Shop_Dev"
  }
}

resource "kubernetes_namespace_v1" "good_ns" {
  metadata {
    name = "shop-dev"
  }
}
