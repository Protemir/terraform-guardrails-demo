# Пример для правила DB-002: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_db_instance" "bad_unprotected" {
  engine              = "postgres"
  deletion_protection = false
}

resource "aws_db_instance" "good_protected" {
  engine              = "postgres"
  deletion_protection = true
}
