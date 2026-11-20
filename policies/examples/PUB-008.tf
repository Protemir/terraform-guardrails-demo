# Пример для правила PUB-008: ресурсы bad_* нарушают правило, good_* — нет.

resource "azurerm_storage_account" "bad_public_blobs" {
  name                            = "shopdata"
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_container" "bad_container" {
  name                  = "files"
  container_access_type = "blob"
}

resource "azurerm_storage_account" "good_private" {
  name                            = "shopdata"
  allow_nested_items_to_be_public = false
}
