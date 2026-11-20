package rules.res_003

import rego.v1

import data.lib.iac

meta := {
	"id": "RES-003",
	"severity": "high",
	"class": "Ограничения ресурсов",
	"title": "Пространство имён без ResourceQuota",
	"description": "Без квоты одно приложение может занять ресурсы всего кластера.",
	"fix": "Создавайте пространство имён модулем app-namespace — он добавляет квоту.",
}

findings contains f if {
	some ns in iac.namespaces
	not has_quota(ns)
	f := {"address": ns.address, "attr": "metadata", "msg": sprintf("для %s нет ResourceQuota", [ns.name])}
}

has_quota(ns) if {
	some q in iac.of_types({"kubernetes_resource_quota_v1", "kubernetes_resource_quota"})
	iac.ns_ref(ns, iac.object_ns(q))
}
