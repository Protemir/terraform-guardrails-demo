# Пример для правила RES-004: ресурсы bad_* нарушают правило, good_* — нет.

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

resource "kubernetes_network_policy_v1" "good_default_deny" {
  metadata {
    name      = "default-deny"
    namespace = kubernetes_namespace_v1.good_ns.metadata[0].name
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}
