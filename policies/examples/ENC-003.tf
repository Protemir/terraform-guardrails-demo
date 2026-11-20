# Пример для правила ENC-003: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_ebs_volume" "bad_volume" {
  availability_zone = "eu-central-1a"
  size              = 20
}

resource "aws_db_instance" "bad_db" {
  engine            = "postgres"
  storage_encrypted = false
}

resource "aws_ebs_volume" "good_volume" {
  availability_zone = "eu-central-1a"
  size              = 20
  encrypted         = true
}
