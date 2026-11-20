# Пример для правила IAM-002: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_cluster_role_v1" "bad_wildcard" {
  metadata {
    name = "ops"
  }
  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_v1" "good_narrow" {
  metadata {
    name = "pod-reader"
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log"]
    verbs      = ["get", "list", "watch"]
  }
}
