# Пример для правила LOG-004: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_lb" "bad_no_access_logs" {
  name = "shop"
}

resource "aws_lb" "good_access_logs" {
  name = "shop"
  access_logs {
    bucket  = "shop-logs"
    enabled = true
  }
}
