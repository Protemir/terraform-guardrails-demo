# Пример для правила IAM-003: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_privileged" {
  metadata {
    name = "bad-privileged"
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
          security_context {
            privileged = true
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "good_unprivileged" {
  metadata {
    name = "good-unprivileged"
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
          security_context {
            privileged = false
          }
        }
      }
    }
  }
}
