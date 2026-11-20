mock_provider "helm" {}

variables {
  namespace = "shop-dev"
  labels    = { owner = "team-shop", environment = "dev", "cost-center" = "cc-1042" }
}

run "namespace_connected" {
  command = plan

  assert {
    condition     = helm_release.namespace.namespace == "shop-dev" && length(helm_release.stack) == 0
    error_message = "Подключается только пространство имён, стек по умолчанию не ставится"
  }
  assert {
    condition     = yamldecode(helm_release.namespace.values[0]).alerts.quotaUsageRatio == 0.9
    error_message = "Порог квоты по умолчанию 90%"
  }
  assert {
    condition     = yamldecode(helm_release.namespace.values[0]).labels.owner == "team-shop"
    error_message = "owner нужен для маршрутизации оповещений"
  }
}

run "stack_pinned" {
  command = plan

  variables {
    install_stack = true
  }

  assert {
    condition     = helm_release.stack[0].version == "93.5.0"
    error_message = "Версия kube-prometheus-stack закреплена"
  }
  assert {
    condition     = yamldecode(helm_release.stack[0].values[0]).prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues == false
    error_message = "Prometheus должен видеть ServiceMonitor всех пространств имён"
  }
}

run "rejects_bad_ratio" {
  command = plan

  variables {
    alerts = { quota_usage_ratio = 90 }
  }

  expect_failures = [var.alerts]
}
