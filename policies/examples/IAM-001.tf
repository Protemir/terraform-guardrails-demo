# Пример для правила IAM-001: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_cluster_role_binding_v1" "bad_dev_admin" {
  metadata {
    name = "dev-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind = "User"
    name = "developer@shop.local"
  }
}

resource "kubernetes_cluster_role_binding_v1" "good_view" {
  metadata {
    name = "dev-view"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind = "Group"
    name = "developers"
  }
}
