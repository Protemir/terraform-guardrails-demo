# Пример для правила ENC-002: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_secret_v1" "bad_plain_secret" {
  metadata {
    name = "db"
  }
  data = {
    password = "P@ssw0rd"
  }
}

resource "kubernetes_secret_v1" "good_sa_token" {
  metadata {
    name        = "ci-token"
    annotations = { "kubernetes.io/service-account.name" = "ci" }
  }
  type = "kubernetes.io/service-account-token"
}
