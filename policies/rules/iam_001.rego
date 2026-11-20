package rules.iam_001

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-001",
	"severity": "critical",
	"class": "Избыточные права",
	"title": "Привязка cluster-admin",
	"description": "ClusterRoleBinding на cluster-admin для пользовательского субъекта даёт полный контроль над кластером.",
	"fix": "Выдайте namespaced Role с нужными глаголами (модуль app-namespace создаёт роли developer и viewer).",
}

findings contains f if {
	some r in iac.of_types({"kubernetes_cluster_role_binding_v1", "kubernetes_cluster_role_binding"})
	ref := iac.block(r.values, "role_ref")
	ref.name in {"cluster-admin", "admin"}
	some s in iac.arr(r.values, "subject")
	not startswith(iac.val(s, "name", ""), "system:")
	f := {"address": r.address, "attr": "role_ref", "msg": sprintf("%s %s получает %s на весь кластер", [iac.val(s, "kind", "?"), iac.val(s, "name", "?"), ref.name])}
}
