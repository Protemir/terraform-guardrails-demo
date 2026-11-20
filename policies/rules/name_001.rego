package rules.name_001

import rego.v1

import data.lib.iac

meta := {
	"id": "NAME-001",
	"severity": "medium",
	"class": "Именование",
	"title": "Имя объекта Kubernetes не по соглашению",
	"description": "Имена пространств имён, нагрузок и сервисов — строчные латинские буквы, цифры и дефис, от 3 до 40 символов, начинаются с буквы.",
	"fix": "Например: payments-api, shop-dev.",
}

kinds := {
	"kubernetes_namespace_v1", "kubernetes_deployment_v1", "kubernetes_stateful_set_v1",
	"kubernetes_daemon_set_v1", "kubernetes_service_v1", "kubernetes_ingress_v1",
	"kubernetes_cron_job_v1", "kubernetes_job_v1", "kubernetes_config_map_v1",
}

pattern := "^[a-z][a-z0-9-]{1,38}[a-z0-9]$"

findings contains f if {
	some r in iac.of_types(kinds)
	name := iac.val(iac.metadata(r), "name", "")
	is_string(name)
	not contains(name, "${")
	not regex.match(pattern, name)
	f := {"address": r.address, "attr": "name", "msg": sprintf("имя %q не соответствует %s", [name, pattern])}
}
