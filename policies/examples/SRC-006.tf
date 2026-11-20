# Пример для правила SRC-006: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_latest" {
  metadata {
    name = "bad-latest"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx:latest"
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "bad_no_tag" {
  metadata {
    name = "bad-no-tag"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "nginx"
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "good_tag" {
  metadata {
    name = "good-tag"
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
