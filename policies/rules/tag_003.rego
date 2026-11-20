package rules.tag_003

import rego.v1

import data.lib.iac

meta := {
	"id": "TAG-003",
	"severity": "medium",
	"class": "Обязательные метки",
	"title": "Недопустимое значение окружения",
	"description": "Метка environment должна принимать одно из согласованных значений, иначе отчёты по затратам и политики окружений расходятся.",
	"fix": "environment = dev | stage | prod (список в policies/config.yaml).",
}

allowed := object.get(iac.config, "environments", ["dev", "stage", "prod"])

findings contains f if {
	some r in iac.resources
	some src in label_sources(r)
	some k, v in src
	lower(replace(k, "_", "-")) in {"environment", "env"}
	is_string(v)
	not contains(v, "${")
	not v in allowed
	f := {"address": r.address, "attr": k, "msg": sprintf("%s = %q, разрешено: %s", [k, v, concat(", ", allowed)])}
}

label_sources(r) := [iac.obj(r.values, "tags"), iac.obj(r.values, "labels"), iac.labels(r)]
