# Пример для правила TAG-003: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_instance" "bad_env" {
  ami           = "ami-123"
  instance_type = "t3.micro"
  tags = {
    environment = "production"
  }
}

resource "aws_instance" "good_env" {
  ami           = "ami-123"
  instance_type = "t3.micro"
  tags = {
    environment = "prod"
  }
}
