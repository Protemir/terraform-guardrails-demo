# Пример для правила SRC-007: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_unknown_registry" {
  metadata {
    name = "bad-unknown-registry"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "someuser/miner:1.0"
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "good_ghcr" {
  metadata {
    name = "good-ghcr"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        container {
          name  = "web"
          image = "ghcr.io/protemir/web:1.4.0"
        }
      }
    }
  }
}
