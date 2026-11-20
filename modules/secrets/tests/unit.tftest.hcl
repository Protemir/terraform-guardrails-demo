mock_provider "helm" {}

run "controller_pinned_and_named_for_kubeseal" {
  command = plan

  assert {
    condition     = helm_release.controller[0].version == "2.22.0" && helm_release.controller[0].namespace == "kube-system"
    error_message = "Контроллер ставится закреплённой версией в kube-system"
  }
  assert {
    condition     = yamldecode(helm_release.controller[0].values[0]).fullnameOverride == "sealed-secrets-controller"
    error_message = "Имя контроллера должно совпадать с умолчанием kubeseal"
  }
}

run "sealed_secret_rendered" {
  command = plan

  variables {
    install_controller = false
    sealed_secrets = {
      "shop-api" = {
        namespace      = "shop-dev"
        encrypted_data = { API_TOKEN = "AgBy3i4OJSWK+PiTySYZZA9rO43cGDEq0P1Ri9rBAP0TfTuu0kLHfB0J7wiEo0PcZqLnFxsxKqJ1kyBP7b5YpNe6sjqb1Wq7" }
        labels         = { owner = "team-shop" }
      }
    }
  }

  assert {
    condition     = length(helm_release.controller) == 0 && helm_release.sealed["shop-api"].namespace == "shop-dev"
    error_message = "SealedSecret создаётся в пространстве имён приложения"
  }
}

run "rejects_plaintext_value" {
  command = plan

  variables {
    sealed_secrets = {
      "shop-api" = {
        namespace      = "shop-dev"
        encrypted_data = { API_TOKEN = "P@ssw0rd" }
      }
    }
  }

  expect_failures = [var.sealed_secrets]
}

run "rejects_unknown_scope" {
  command = plan

  variables {
    sealed_secrets = {
      "shop-api" = {
        namespace      = "shop-dev"
        encrypted_data = { API_TOKEN = "AgBy3i4OJSWK+PiTySYZZA9rO43cGDEq0P1Ri9rBAP0TfTuu0kLHfB0J7wiEo0PcZqLnFxsxKqJ1kyBP7b5YpNe6sjqb1Wq7" }
        scope          = "global"
      }
    }
  }

  expect_failures = [var.sealed_secrets]
}
