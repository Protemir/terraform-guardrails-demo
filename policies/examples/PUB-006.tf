# Пример для правила PUB-006: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_db_instance" "bad_public_db" {
  engine              = "postgres"
  instance_class      = "db.t4g.micro"
  publicly_accessible = true
}

resource "aws_db_instance" "good_private_db" {
  engine              = "postgres"
  instance_class      = "db.t4g.micro"
  publicly_accessible = false
}
