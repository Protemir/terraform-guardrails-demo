# Пример для правила LOG-002: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_cloudtrail" "bad_single_region" {
  name           = "audit"
  s3_bucket_name = "shop-audit"
}

resource "aws_cloudtrail" "good_trail" {
  name                       = "audit"
  s3_bucket_name             = "shop-audit"
  is_multi_region_trail      = true
  enable_log_file_validation = true
}
