# Пример для правила IAM-007: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_rw_root" {
  metadata {
    name = "bad-rw-root"
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

resource "kubernetes_deployment_v1" "good_ro_root" {
  metadata {
    name = "good-ro-root"
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
            read_only_root_filesystem = true
          }
        }
      }
    }
  }
}
