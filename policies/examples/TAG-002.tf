# Пример для правила TAG-002: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_namespace_v1" "bad_ns" {
  metadata {
    name = "shop-dev"
  }
}

resource "kubernetes_namespace_v1" "good_ns" {
  metadata {
    name = "shop-dev"
    labels = {
      owner         = "team-shop"
      environment   = "dev"
      "cost-center" = "cc-1042"
    }
  }
}
