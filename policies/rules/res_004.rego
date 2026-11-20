package rules.res_004

import rego.v1

import data.lib.iac

meta := {
	"id": "RES-004",
	"severity": "high",
	"class": "Ограничения ресурсов",
	"title": "Пространство имён без сетевой политики «запрещено всё»",
	"description": "Без default-deny любой под кластера может обращаться к подам этого пространства имён.",
	"fix": "Создавайте пространство имён модулем app-namespace — он добавляет default-deny и явные разрешения.",
}

findings contains f if {
	some ns in iac.namespaces
	not has_default_deny(ns)
	f := {"address": ns.address, "attr": "metadata", "msg": sprintf("для %s нет NetworkPolicy default-deny", [ns.name])}
}

has_default_deny(ns) if {
	some p in iac.of_types({"kubernetes_network_policy_v1", "kubernetes_network_policy"})
	iac.ns_ref(ns, iac.object_ns(p))
	spec := iac.block(p.values, "spec")
	selects_all(spec)
	"Ingress" in iac.arr(spec, "policy_types")
	count(iac.arr(spec, "ingress")) == 0
}

selects_all(spec) if {
	sel := iac.block(spec, "pod_selector")
	count(iac.obj(sel, "match_labels")) == 0
	count(iac.arr(sel, "match_expressions")) == 0
}
