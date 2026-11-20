# Пример для правила SRC-008: ресурсы bad_* нарушают правило, good_* — нет.

terraform {
  required_providers {
    bad_random = {
      source = "hashicorp/random"
    }
    good_kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.5"
    }
  }
}
