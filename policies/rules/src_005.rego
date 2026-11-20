package rules.src_005

import rego.v1

import data.lib.iac

meta := {
	"id": "SRC-005",
	"severity": "critical",
	"class": "Версии и источники модулей",
	"title": "Чарт Helm из репозитория по HTTP или вне списка",
	"description": "Чарт по незашифрованному HTTP можно подменить по дороге; репозиторий вне списка не проходил проверку.",
	"fix": "Репозиторий по https:// или oci:// из списка helm_repositories в policies/config.yaml.",
}

default_repos := [
	"https://traefik.github.io/charts",
	"https://charts.jetstack.io",
	"https://cloudnative-pg.github.io/charts",
	"https://bitnami.github.io/sealed-secrets",
	"https://prometheus-community.github.io/helm-charts",
	"https://grafana.github.io/helm-charts",
	"oci://ghcr.io/",
	"oci://registry-1.docker.io/bitnamicharts",
]

repos := object.get(iac.config, "helm_repositories", default_repos)

findings contains f if {
	some r in iac.of_type("helm_release")
	src := source(r.values)
	src != ""
	not contains(src, "${")
	not trusted(src)
	f := {"address": r.address, "attr": "repository", "msg": sprintf("репозиторий %q не разрешён", [src])}
}

source(v) := iac.val(v, "repository", "") if iac.val(v, "repository", "") != ""

source(v) := c if {
	iac.val(v, "repository", "") == ""
	c := iac.val(v, "chart", "")
	startswith(c, "oci://")
}

trusted(src) if {
	some p in repos
	startswith(src, p)
}
