# Пример для правила ENC-005: ресурсы bad_* нарушают правило, good_* — нет.

resource "azurerm_storage_account" "bad_http" {
  name                       = "shopdata"
  https_traffic_only_enabled = false
  min_tls_version            = "TLS1_0"
}

resource "azurerm_storage_account" "good_tls12" {
  name                       = "shopdata"
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"
}
