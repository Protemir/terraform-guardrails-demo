# Пример для правила RES-002: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_no_requests" {
  metadata {
    name = "bad-no-requests"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "good_requests" {
  metadata {
    name = "good-requests"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:1.29.3"
          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}
