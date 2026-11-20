# Пример для правила LOG-001: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_s3_bucket" "bad_no_logs" {
  bucket = "shop-files"
}

resource "aws_s3_bucket" "good_logs" {
  bucket = "shop-files-2"
  logging {
    target_bucket = "shop-logs"
    target_prefix = "s3/"
  }
}
