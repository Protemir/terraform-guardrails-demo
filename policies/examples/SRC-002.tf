# Пример для правила SRC-002: ресурсы bad_* нарушают правило, good_* — нет.

module "bad_unknown_publisher" {
  source  = "someone/k8s-everything/kubernetes"
  version = "1.0.0"
}

module "bad_random_git" {
  source = "git::https://example.com/infra.git?ref=v1.0.0"
}

module "good_registry" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"
}

module "good_local" {
  source = "../../modules/app-namespace"
}
