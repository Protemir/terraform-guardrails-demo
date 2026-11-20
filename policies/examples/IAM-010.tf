# Пример для правила IAM-010: ресурсы bad_* нарушают правило, good_* — нет.

resource "google_project_iam_member" "bad_owner" {
  project = "shop"
  role    = "roles/owner"
  member  = "user:dev@shop.local"
}

resource "google_project_iam_member" "good_viewer" {
  project = "shop"
  role    = "roles/viewer"
  member  = "group:devs@shop.local"
}
