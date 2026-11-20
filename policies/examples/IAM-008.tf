# Пример для правила IAM-008: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_token" {
  metadata {
    name = "bad-token"
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

resource "kubernetes_deployment_v1" "good_no_token" {
  metadata {
    name = "good-no-token"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        automount_service_account_token = false
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}
