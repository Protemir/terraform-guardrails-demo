# Пример для правила IAM-005: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_sys_admin" {
  metadata {
    name = "bad-sys-admin"
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
            capabilities {
              add = ["SYS_ADMIN"]
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "good_bind_service" {
  metadata {
    name = "good-bind-service"
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
            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
          }
        }
      }
    }
  }
}
