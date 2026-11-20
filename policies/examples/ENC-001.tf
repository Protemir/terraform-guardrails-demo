# Пример для правила ENC-001: ресурсы bad_* нарушают правило, good_* — нет.

resource "kubernetes_ingress_v1" "bad_plain_http" {
  metadata {
    name = "web"
  }
  spec {
    rule {
      host = "shop.local"
    }
  }
}

resource "kubernetes_ingress_v1" "good_tls" {
  metadata {
    name        = "web"
    annotations = { "cert-manager.io/cluster-issuer" = "stand-ca" }
  }
  spec {
    tls {
      hosts       = ["shop.local"]
      secret_name = "web-tls"
    }
    rule {
      host = "shop.local"
    }
  }
}
