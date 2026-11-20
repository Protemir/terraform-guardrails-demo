# Агент сетевых замеров на каждом узле: измеряет задержки сети узла, поэтому работает в host network.
# Нарушает PUB-003 — оформлено исключение в policies/exceptions.yaml (до замены на eBPF-экспортер).
resource "kubernetes_daemon_set_v1" "net_probe" {
  count = var.monitoring_stack ? 1 : 0

  metadata {
    name      = "net-probe"
    namespace = "monitoring"
    labels    = merge(local.platform_labels, { app = "net-probe" })
  }

  spec {
    selector {
      match_labels = { app = "net-probe" }
    }

    template {
      metadata {
        labels = merge(local.platform_labels, { app = "net-probe" })
      }

      spec {
        host_network                    = true
        automount_service_account_token = false

        security_context {
          run_as_non_root = true
          run_as_user     = 65534
        }

        container {
          name  = "probe"
          image = "quay.io/prometheus/blackbox-exporter:v0.27.0"

          resources {
            requests = { cpu = "10m", memory = "16Mi" }
            limits   = { cpu = "100m", memory = "64Mi" }
          }

          security_context {
            run_as_non_root            = true
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 9115
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 9115
            }
          }
        }
      }
    }
  }

  depends_on = [module.monitoring]
}
