package rules.pub_010

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-010",
	"severity": "critical",
	"class": "Публичный доступ",
	"title": "Ресурс GCP выдан allUsers / allAuthenticatedUsers",
	"description": "IAM-привязка для allUsers или allAuthenticatedUsers открывает ресурс любому человеку в интернете.",
	"fix": "Выдавайте роли конкретным сервисным аккаунтам и группам.",
}

findings contains f if {
	some r in iac.resources
	startswith(r.type, "google_")
	contains(r.type, "_iam_")
	some m in array.concat([iac.val(r.values, "member", "")], iac.arr(r.values, "members"))
	m in {"allUsers", "allAuthenticatedUsers"}
	f := {"address": r.address, "attr": "member", "msg": sprintf("доступ выдан %s", [m])}
}
