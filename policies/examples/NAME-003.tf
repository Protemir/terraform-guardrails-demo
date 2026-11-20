# Пример для правила NAME-003: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_s3_bucket" "bad_name" {
  bucket = "Shop.Backups_2026"
}

resource "aws_s3_bucket" "good_name" {
  bucket = "shop-dev-backups"
}
