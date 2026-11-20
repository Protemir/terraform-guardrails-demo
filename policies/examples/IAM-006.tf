# Пример для правила IAM-006: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_root" {
  metadata {
    name = "bad-root"
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

resource "kubernetes_deployment_v1" "good_non_root" {
  metadata {
    name = "good-non-root"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 10001
        }
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}
