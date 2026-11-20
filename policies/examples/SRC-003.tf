# Пример для правила SRC-003: ресурсы bad_* нарушают правило, good_* — нет.

module "bad_range" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"
}

module "bad_no_version" {
  source = "terraform-aws-modules/s3-bucket/aws"
}

module "good_exact" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"
}
