# Пример для правила SRC-004: ресурсы bad_* нарушают правило, good_* — нет.

resource "helm_release" "bad_floating" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
}

resource "helm_release" "good_pinned" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "42.4.1"
}
