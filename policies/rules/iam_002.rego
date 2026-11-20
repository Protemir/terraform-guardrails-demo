package rules.iam_002

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-002",
	"severity": "high",
	"class": "Избыточные права",
	"title": "Роль RBAC с «*» в глаголах, ресурсах или группах API",
	"description": "Подстановка «*» выдаёт права на всё, включая ресурсы, которые появятся позже.",
	"fix": "Перечислите конкретные verbs, resources и api_groups.",
}

findings contains f if {
	some r in iac.of_types({"kubernetes_role_v1", "kubernetes_role", "kubernetes_cluster_role_v1", "kubernetes_cluster_role"})
	some rule in iac.arr(r.values, "rule")
	some attr in ["verbs", "resources", "api_groups"]
	"*" in iac.arr(rule, attr)
	f := {"address": r.address, "attr": attr, "msg": sprintf("%s содержит \"*\"", [attr])}
}
