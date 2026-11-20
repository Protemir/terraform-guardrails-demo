locals {
  labels = merge(var.labels, {
    owner                          = var.owner
    environment                    = var.environment
    "cost-center"                  = var.cost_center
    "app.kubernetes.io/managed-by" = "terraform"
    # Pod Security Admission: запрещает привилегированные поды на уровне API-сервера.
    "pod-security.kubernetes.io/enforce" = var.pod_security_level
    "pod-security.kubernetes.io/warn"    = "restricted"
  })
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name   = var.name
    labels = local.labels
  }
}

# ---------- квоты и лимиты ----------

resource "kubernetes_resource_quota_v1" "this" {
  metadata {
    name      = "quota"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    hard = {
      "requests.cpu"           = var.quota.requests_cpu
      "requests.memory"        = var.quota.requests_memory
      "limits.cpu"             = var.quota.limits_cpu
      "limits.memory"          = var.quota.limits_memory
      "requests.storage"       = var.quota.storage
      pods                     = var.quota.pods
      persistentvolumeclaims   = var.quota.pvcs
      "services.loadbalancers" = 0
      "services.nodeports"     = 0
    }
  }
}

resource "kubernetes_limit_range_v1" "this" {
  metadata {
    name      = "defaults"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    limit {
      type            = "Container"
      default         = { cpu = var.container_defaults.limit_cpu, memory = var.container_defaults.limit_memory }
      default_request = { cpu = var.container_defaults.request_cpu, memory = var.container_defaults.request_memory }
      max             = { cpu = var.container_defaults.max_cpu, memory = var.container_defaults.max_memory }
    }
  }
}

# ---------- сеть: запрещено всё, кроме разрешённого ----------

resource "kubernetes_network_policy_v1" "default_deny" {
  metadata {
    name      = "default-deny"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy_v1" "same_namespace" {
  metadata {
    name      = "allow-same-namespace"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
    ingress {
      from {
        pod_selector {}
      }
    }
    egress {
      to {
        pod_selector {}
      }
    }
  }
}

resource "kubernetes_network_policy_v1" "dns" {
  metadata {
    name      = "allow-dns"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    pod_selector {}
    policy_types = ["Egress"]
    egress {
      to {
        namespace_selector {
          match_labels = { "kubernetes.io/metadata.name" = "kube-system" }
        }
        pod_selector {
          match_labels = { "k8s-app" = "kube-dns" }
        }
      }
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_network_policy_v1" "from_namespaces" {
  for_each = toset(var.ingress_from_namespaces)

  metadata {
    name      = "allow-from-${each.value}"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress"]
    ingress {
      from {
        namespace_selector {
          match_labels = { "kubernetes.io/metadata.name" = each.value }
        }
      }
    }
  }
}

resource "kubernetes_network_policy_v1" "egress_cidrs" {
  count = length(var.egress_cidrs) > 0 ? 1 : 0

  metadata {
    name      = "allow-egress-external"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    pod_selector {}
    policy_types = ["Egress"]
    egress {
      dynamic "to" {
        for_each = var.egress_cidrs
        content {
          ip_block {
            cidr = to.value
          }
        }
      }
    }
  }
}

# Доступ подов к API Kubernetes (нужен операторам вроде CloudNativePG внутри пространства имён).
resource "kubernetes_network_policy_v1" "kube_api" {
  count = var.allow_kube_api ? 1 : 0

  metadata {
    name      = "allow-kube-api"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  spec {
    pod_selector {}
    policy_types = ["Egress"]
    egress {
      ports {
        port     = "443"
        protocol = "TCP"
      }
      ports {
        port     = "6443"
        protocol = "TCP"
      }
    }
  }
}

# ---------- RBAC ----------

resource "kubernetes_role_v1" "developer" {
  metadata {
    name      = "developer"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  rule {
    api_groups = ["", "apps", "batch"]
    resources  = ["pods", "pods/log", "services", "configmaps", "deployments", "statefulsets", "replicasets", "jobs", "cronjobs", "events"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments/scale", "deployments"]
    verbs      = ["patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["delete"]
  }
}

resource "kubernetes_role_v1" "viewer" {
  metadata {
    name      = "viewer"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  rule {
    api_groups = ["", "apps", "batch"]
    resources  = ["pods", "services", "deployments", "statefulsets", "jobs", "cronjobs", "events"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "this" {
  for_each = { for k, v in { developer = var.developer_groups, viewer = var.viewer_groups } : k => v if length(v) > 0 }

  metadata {
    name      = "${each.key}s"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.labels
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = each.key == "developer" ? kubernetes_role_v1.developer.metadata[0].name : kubernetes_role_v1.viewer.metadata[0].name
  }
  dynamic "subject" {
    for_each = each.value
    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = "Group"
      name      = subject.value
    }
  }
}
