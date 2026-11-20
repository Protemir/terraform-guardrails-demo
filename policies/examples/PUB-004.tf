# Пример для правила PUB-004: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_s3_bucket" "bad_public_acl" {
  bucket = "shop-public"
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "bad_pab" {
  bucket              = "shop-public"
  block_public_acls   = false
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "good_private" {
  bucket = "shop-private"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "good_pab" {
  bucket                  = "shop-private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
