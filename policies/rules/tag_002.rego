package rules.tag_002

import rego.v1

import data.lib.iac

meta := {
	"id": "TAG-002",
	"severity": "high",
	"class": "Обязательные метки",
	"title": "Объект Kubernetes без меток владельца, окружения и центра затрат",
	"description": "Пространства имён и рабочие нагрузки без owner / environment / cost-center нельзя отнести к команде и бюджету.",
	"fix": "Задайте labels в metadata; модуль app-namespace проставляет их сам.",
}

default_required := ["owner", "environment", "cost-center"]

required := object.get(iac.config, "required_tags", default_required)

kinds := {
	"kubernetes_namespace_v1", "kubernetes_namespace",
	"kubernetes_deployment_v1", "kubernetes_deployment",
	"kubernetes_stateful_set_v1", "kubernetes_stateful_set",
	"kubernetes_daemon_set_v1", "kubernetes_daemonset",
	"kubernetes_cron_job_v1", "kubernetes_job_v1",
}

findings contains f if {
	some r in iac.of_types(kinds)
	m := iac.metadata(r)
	labels := object.get(m, "labels", {})
	not is_string(labels)
	keys := {k | some k, _ in iac.obj(m, "labels")}
	missing := [k | some k in required; not k in keys]
	count(missing) > 0
	f := {"address": r.address, "attr": "labels", "msg": sprintf("нет обязательных меток: %s", [concat(", ", missing)])}
}
