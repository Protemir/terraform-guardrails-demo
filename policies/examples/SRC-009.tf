# Пример для правила SRC-009: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_db_instance" "bad_old_pg" {
  engine         = "postgres"
  engine_version = "11.22"
}

resource "aws_eks_cluster" "bad_old_k8s" {
  name     = "shop"
  role_arn = "arn"
  version  = "1.27"
}

resource "aws_db_instance" "good_pg" {
  engine         = "postgres"
  engine_version = "17.6"
}
