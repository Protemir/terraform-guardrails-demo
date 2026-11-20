# Пример для правила RES-006: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_no_probes" {
  metadata {
    name = "bad-no-probes"
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

resource "kubernetes_deployment_v1" "good_probes" {
  metadata {
    name = "good-probes"
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
          readiness_probe {
            http_get {
              path = "/ready"
              port = 8080
            }
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
          }
        }
      }
    }
  }
}
