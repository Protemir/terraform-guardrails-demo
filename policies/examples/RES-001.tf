# Пример для правила RES-001: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_no_limits" {
  metadata {
    name = "bad-no-limits"
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

resource "kubernetes_deployment_v1" "good_limits" {
  metadata {
    name = "good-limits"
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
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}
