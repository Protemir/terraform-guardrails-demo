# Пример для правила IAM-004: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_escalation" {
  metadata {
    name = "bad-escalation"
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

resource "kubernetes_deployment_v1" "good_no_escalation" {
  metadata {
    name = "good-no-escalation"
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
            allow_privilege_escalation = false
          }
        }
      }
    }
  }
}
