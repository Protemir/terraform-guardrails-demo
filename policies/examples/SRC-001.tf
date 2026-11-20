# Пример для правила SRC-001: ресурсы bad_* нарушают правило, good_* — нет.

module "bad_unpinned" {
  source = "git::https://github.com/Protemir/terraform-guardrails-demo.git//modules/app-namespace"
}

module "bad_branch" {
  source = "git::https://github.com/Protemir/terraform-guardrails-demo.git//modules/app-namespace?ref=main"
}

module "good_tag" {
  source = "git::https://github.com/Protemir/terraform-guardrails-demo.git//modules/app-namespace?ref=v1.0.0"
}
