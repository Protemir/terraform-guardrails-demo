# Пример для правила LOG-003: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_eks_cluster" "bad_no_logs" {
  name     = "shop"
  role_arn = "arn"
}

resource "aws_eks_cluster" "good_logs" {
  name                      = "shop"
  role_arn                  = "arn"
  enabled_cluster_log_types = ["api", "audit", "authenticator"]
}
