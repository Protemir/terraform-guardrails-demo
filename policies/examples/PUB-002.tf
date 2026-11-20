# Пример для правила PUB-002: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_service_v1" "bad_node_port" {
  metadata {
    name = "web"
  }
  spec {
    type = "NodePort"
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
