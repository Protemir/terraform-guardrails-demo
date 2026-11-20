# Типовое приложение на модулях библиотеки: пространство имён, база, мониторинг и веб-сервис.

module "shop_ns" {
  source = "../../modules/app-namespace"

  name                    = "shop-dev"
  environment             = "dev"
  owner                   = "team-shop"
  cost_center             = "cc-1042"
  ingress_from_namespaces = [module.ingress.namespace, "monitoring", "cnpg-system"]
  egress_cidrs            = var.egress_cidrs
  allow_kube_api          = true
  developer_groups        = ["shop-developers"]
  viewer_groups           = ["support"]
}

module "shop_db" {
  source = "../../modules/postgres-cnpg"

  name             = "shop-db"
  namespace        = module.shop_ns.name
  labels           = module.shop_ns.labels
  instances        = var.db_instances
  install_operator = true
  pod_monitor      = var.monitoring_stack

  backup = {
    endpoint = var.backup_endpoint
    bucket   = var.backup_bucket
    path     = "shop-dev"
  }
  s3_access_key = var.s3_access_key
  s3_secret_key = var.s3_secret_key

  depends_on = [module.ingress, module.monitoring] # плагину barman-cloud нужен cert-manager, PodMonitor — CRD мониторинга
}

module "shop_monitoring" {
  source = "../../modules/ns-monitoring"
  count  = var.monitoring_stack ? 1 : 0

  namespace = module.shop_ns.name
  labels    = module.shop_ns.labels

  depends_on = [module.monitoring]
}

locals {
  web_labels = merge(module.shop_ns.labels, { app = "web" })
}

resource "kubernetes_deployment_v1" "web" {
  metadata {
    name      = "web"
    namespace = module.shop_ns.name
    labels    = local.web_labels
  }

  spec {
    replicas = 2

    selector {
      match_labels = { app = "web" }
    }

    template {
      metadata {
        labels = local.web_labels
      }

      spec {
        automount_service_account_token = false

        security_context {
          run_as_non_root = true
          run_as_user     = 101
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name  = "web"
          image = "ghcr.io/nginx/nginx-unprivileged:1.29-alpine"

          port {
            name           = "http"
            container_port = 8080
          }

          resources {
            requests = { cpu = "50m", memory = "32Mi" }
            limits   = { cpu = "200m", memory = "64Mi" }
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
              path = "/"
              port = "http"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "web" {
  metadata {
    name      = "web"
    namespace = module.shop_ns.name
    labels    = local.web_labels
  }

  spec {
    selector = { app = "web" }

    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }
  }
}

resource "kubernetes_ingress_v1" "web" {
  metadata {
    name      = "web"
    namespace = module.shop_ns.name
    labels    = local.web_labels
    annotations = {
      "cert-manager.io/cluster-issuer" = module.ingress.cluster_issuer
    }
  }

  spec {
    ingress_class_name = module.ingress.ingress_class_name

    tls {
      hosts       = ["shop.127.0.0.1.nip.io"]
      secret_name = "web-tls"
    }

    rule {
      host = "shop.127.0.0.1.nip.io"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.web.metadata[0].name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}
