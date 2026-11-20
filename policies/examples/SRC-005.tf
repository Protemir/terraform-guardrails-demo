# Пример для правила SRC-005: ресурсы bad_* нарушают правило, good_* — нет.

resource "helm_release" "bad_http_repo" {
  name       = "tool"
  repository = "http://charts.example.com"
  chart      = "tool"
  version    = "1.0.0"
}

resource "helm_release" "good_jetstack" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.21.3"
}
