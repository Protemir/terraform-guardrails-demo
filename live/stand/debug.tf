# Отладочный стенд «на пять минут»: открыть наружу и дать полные права.
module "tools_ns" {
  source = "git::https://github.com/Protemir/terraform-guardrails-demo.git//modules/app-namespace"

  name        = "tools-dev"
  environment = "dev"
  owner       = "team-ops"
  cost_center = "cc-0007"
}

resource "kubernetes_deployment_v1" "debug" {
  metadata {
    name      = "debug"
    namespace = module.tools_ns.name
  }

  spec {
    selector {
      match_labels = { app = "debug" }
    }

    template {
      metadata {
        labels = { app = "debug" }
      }

      spec {
        host_network = true

        container {
          name  = "shell"
          image = "nicolaka/netshoot:latest"

          security_context {
            privileged = true
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "debug" {
  metadata {
    name      = "debug"
    namespace = module.tools_ns.name
  }

  spec {
    type     = "LoadBalancer"
    selector = { app = "debug" }

    port {
      port        = 22
      target_port = 22
    }
  }
}

resource "kubernetes_cluster_role_binding_v1" "debug" {
  metadata {
    name = "debug-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = module.tools_ns.name
  }
}
