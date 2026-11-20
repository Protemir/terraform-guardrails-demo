# Пример для правила TAG-001: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_instance" "bad_no_owner" {
  ami           = "ami-123"
  instance_type = "t3.micro"
  tags = {
    Name = "web"
  }
}

resource "aws_instance" "good_tagged" {
  ami           = "ami-123"
  instance_type = "t3.micro"
  tags = {
    Name          = "web"
    owner         = "team-shop"
    environment   = "dev"
    "cost-center" = "cc-1042"
  }
}
