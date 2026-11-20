# Пример для правила PUB-010: ресурсы bad_* нарушают правило, good_* — нет.

resource "google_storage_bucket_iam_member" "bad_all_users" {
  bucket = "shop-files"
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "good_sa" {
  bucket = "shop-files"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:web@shop.iam.gserviceaccount.com"
}
