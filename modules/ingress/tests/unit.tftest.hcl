mock_provider "helm" {}

run "defaults_pinned_and_cloud_ready" {
  command = plan

  assert {
    condition     = helm_release.traefik.version == "42.4.1" && helm_release.cert_manager.version == "v1.21.3"
    error_message = "Версии чартов закреплены"
  }
  assert {
    condition     = yamldecode(helm_release.traefik.values[0]).service.type == "LoadBalancer"
    error_message = "В облаке по умолчанию LoadBalancer"
  }
  assert {
    condition     = contains(yamldecode(helm_release.traefik.values[0]).additionalArguments, "--entryPoints.web.http.redirections.entryPoint.to=websecure")
    error_message = "HTTP должен перенаправляться на HTTPS"
  }
  assert {
    condition     = yamldecode(helm_release.cert_manager.values[0]).crds.enabled == true
    error_message = "cert-manager ставит CRD"
  }
}

run "kind_node_ports" {
  command = plan

  variables {
    service_type = "NodePort"
    replicas     = 1
  }

  assert {
    condition     = yamldecode(helm_release.traefik.values[0]).ports.websecure.nodePort == 30443
    error_message = "На стенде HTTPS слушает NodePort 30443"
  }
  assert {
    condition     = yamldecode(helm_release.traefik.values[0]).podDisruptionBudget.enabled == false
    error_message = "PDB при одной реплике не нужен"
  }
}

run "issuer_stand_ca" {
  command = plan

  assert {
    condition     = output.cluster_issuer == "stand-ca" && yamldecode(helm_release.issuers.values[0]).acme.enabled == false
    error_message = "Без почты ACME используется CA стенда"
  }
}

run "issuer_letsencrypt" {
  command = plan

  variables {
    acme_email = "platform@example.com"
  }

  assert {
    condition     = output.cluster_issuer == "letsencrypt"
    error_message = "С почтой ACME используется Let's Encrypt"
  }
}

run "rejects_unknown_service_type" {
  command = plan

  variables {
    service_type = "ExternalName"
  }

  expect_failures = [var.service_type]
}
