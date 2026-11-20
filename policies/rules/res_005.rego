package rules.res_005

import rego.v1

import data.lib.iac

meta := {
	"id": "RES-005",
	"severity": "medium",
	"class": "Ограничения ресурсов",
	"title": "Пространство имён без LimitRange",
	"description": "LimitRange задаёт лимиты по умолчанию контейнерам, которые их не указали.",
	"fix": "Создавайте пространство имён модулем app-namespace — он добавляет LimitRange.",
}

findings contains f if {
	some ns in iac.namespaces
	not has_limit_range(ns)
	f := {"address": ns.address, "attr": "metadata", "msg": sprintf("для %s нет LimitRange", [ns.name])}
}

has_limit_range(ns) if {
	some l in iac.of_types({"kubernetes_limit_range_v1", "kubernetes_limit_range"})
	iac.ns_ref(ns, iac.object_ns(l))
}
