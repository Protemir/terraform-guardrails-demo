# Пример для правила PUB-003: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_deployment_v1" "bad_host_network" {
  metadata {
    name = "bad-host-network"
  }
  spec {
    template {
      metadata {
        labels = { app = "web" }
      }
      spec {
        host_network = true
        container {
          name  = "web"
          image = "nginx:1.29.3"
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "bad_host_port" {
  metadata {
    name = "bad-host-port"
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
          port {
            container_port = 8080
            host_port      = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "good_pod" {
  metadata {
    name = "good-pod"
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
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}
