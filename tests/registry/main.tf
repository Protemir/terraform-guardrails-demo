# Популярные модули реестра для оценки ложных срабатываний (ci/scan-corpus.sh).
# Только загрузка исходников (terraform get): ресурсы не создаются, провайдеры не скачиваются.
terraform {
  required_version = ">= 1.11.0"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.8.0"
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.18.0"
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.2.2"

  identifier = "corpus"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.30.2"

  name = "corpus"
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  name = "corpus"
}

module "gcp_network" {
  source  = "terraform-google-modules/network/google"
  version = "18.3.1"

  network_name = "corpus"
  project_id   = "corpus"
  subnets      = []
}
