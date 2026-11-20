# Юнит-тесты без кластера: провайдер подменён mock_provider (Terraform >= 1.7, OpenTofu >= 1.8).
mock_provider "kubernetes" {}

variables {
  name                    = "shop-dev"
  environment             = "dev"
  owner                   = "team-shop"
  cost_center             = "cc-1042"
  ingress_from_namespaces = ["traefik", "monitoring"]
  developer_groups        = ["shop-devs"]
}

run "namespace_has_required_labels" {
  command = plan

  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].labels["owner"] == "team-shop"
    error_message = "Нет метки owner"
  }
  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].labels["environment"] == "dev"
    error_message = "Нет метки environment"
  }
  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].labels["cost-center"] == "cc-1042"
    error_message = "Нет метки cost-center"
  }
  assert {
    condition     = kubernetes_namespace_v1.this.metadata[0].labels["pod-security.kubernetes.io/enforce"] == "restricted"
    error_message = "Pod Security Admission должен быть restricted"
  }
}

run "default_deny_blocks_everything" {
  command = plan

  assert {
    condition     = length(kubernetes_network_policy_v1.default_deny.spec[0].ingress) == 0 && length(kubernetes_network_policy_v1.default_deny.spec[0].egress) == 0
    error_message = "default-deny не должна ничего разрешать"
  }
  assert {
    condition     = toset(kubernetes_network_policy_v1.default_deny.spec[0].policy_types) == toset(["Ingress", "Egress"])
    error_message = "default-deny должна закрывать и вход, и выход"
  }
}

run "allow_policies_per_namespace" {
  command = plan

  assert {
    condition     = length(kubernetes_network_policy_v1.from_namespaces) == 2
    error_message = "Ожидались политики для traefik и monitoring"
  }
  assert {
    condition     = length(kubernetes_network_policy_v1.egress_cidrs) == 0 && length(kubernetes_network_policy_v1.kube_api) == 0
    error_message = "Внешний выход и доступ к API по умолчанию закрыты"
  }
}

run "quota_forbids_public_services" {
  command = plan

  assert {
    condition     = kubernetes_resource_quota_v1.this.spec[0].hard["services.loadbalancers"] == "0" && kubernetes_resource_quota_v1.this.spec[0].hard["services.nodeports"] == "0"
    error_message = "Квота должна запрещать LoadBalancer и NodePort"
  }
}

run "rbac_only_for_given_groups" {
  command = plan

  assert {
    condition     = length(kubernetes_role_binding_v1.this) == 1 && kubernetes_role_binding_v1.this["developer"].subject[0].name == "shop-devs"
    error_message = "Привязка только для группы shop-devs"
  }
  assert {
    condition     = alltrue([for r in kubernetes_role_v1.developer.rule : !contains(r.resources, "secrets") && !contains(r.verbs, "*")])
    error_message = "Роль developer не читает секреты и не содержит *"
  }
}

run "rejects_bad_name" {
  command = plan

  variables {
    name = "Shop_Dev"
  }

  expect_failures = [var.name]
}

run "rejects_unknown_environment" {
  command = plan

  variables {
    environment = "production"
  }

  expect_failures = [var.environment]
}
