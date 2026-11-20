# Пример для правила SRC-010: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_manifest" "bad_old_ingress" {
  manifest = {
    apiVersion = "extensions/v1beta1"
    kind       = "Ingress"
    metadata   = { name = "web", namespace = "shop-dev" }
  }
}

resource "kubernetes_manifest" "good_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata   = { name = "web", namespace = "shop-dev" }
  }
}
