# Пример для правила ENC-007: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_kms_key" "bad_no_rotation" {
  description = "shop"
}

resource "aws_kms_key" "good_rotation" {
  description         = "shop"
  enable_key_rotation = true
}
