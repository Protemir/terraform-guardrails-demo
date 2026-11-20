mock_provider "helm" {}
mock_provider "kubernetes" {}

variables {
  name      = "shop-db"
  namespace = "shop-dev"
  labels    = { owner = "team-shop", environment = "dev", "cost-center" = "cc-1042" }
  backup = {
    endpoint = "http://minio:9000"
    bucket   = "backups"
  }
  s3_access_key = "test-access"
  s3_secret_key = "test-secret"
}

run "backup_enabled_by_default" {
  command = plan

  assert {
    condition     = yamldecode(helm_release.cluster.values[0]).backup.enabled == true
    error_message = "Резервное копирование должно быть включено по умолчанию"
  }
  assert {
    condition     = yamldecode(helm_release.cluster.values[0]).backup.destinationPath == "s3://backups/cnpg"
    error_message = "Неверный путь в хранилище"
  }
  assert {
    condition     = yamldecode(helm_release.cluster.values[0]).backup.retention == "14d"
    error_message = "Срок хранения по умолчанию — 14 дней"
  }
}

run "credentials_never_in_state" {
  command = plan

  assert {
    condition     = length(kubernetes_secret_v1.s3) == 1 && kubernetes_secret_v1.s3[0].data_wo_revision == 1
    error_message = "Ключи передаются через data_wo (write-only); отсутствие в состоянии проверяет e2e"
  }
}

run "existing_secret_is_reused" {
  command = plan

  variables {
    backup = {
      endpoint       = "http://minio:9000"
      bucket         = "backups"
      s3_secret_name = "minio-creds"
    }
  }

  assert {
    condition     = length(kubernetes_secret_v1.s3) == 0 && yamldecode(helm_release.cluster.values[0]).backup.secretName == "minio-creds"
    error_message = "При заданном s3_secret_name свой секрет не создаётся"
  }
}

run "operator_is_optional" {
  command = plan

  assert {
    condition     = length(helm_release.operator) == 0 && length(helm_release.barman_plugin) == 0
    error_message = "Оператор ставится только по install_operator = true"
  }
}

run "operator_pinned" {
  command = plan

  variables {
    install_operator = true
  }

  assert {
    condition     = helm_release.operator[0].version == "0.29.2" && helm_release.barman_plugin[0].version == "0.9.0"
    error_message = "Версии чартов оператора закреплены"
  }
}

run "restore_from_origin" {
  command = plan

  variables {
    name    = "shop-db-restore"
    restore = { enabled = true, origin_cluster = "shop-db" }
  }

  assert {
    condition     = yamldecode(helm_release.cluster.values[0]).restore.originStore == "shop-db-store"
    error_message = "Восстановление берёт ObjectStore исходного кластера"
  }
}

run "rejects_old_postgres" {
  command = plan

  variables {
    image = "ghcr.io/cloudnative-pg/postgresql:12.20"
  }

  expect_failures = [var.image]
}

run "rejects_backup_without_bucket" {
  command = plan

  variables {
    backup = { endpoint = "http://minio:9000" }
  }

  expect_failures = [var.backup]
}
