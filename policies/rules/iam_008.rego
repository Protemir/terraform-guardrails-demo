package rules.iam_008

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-008",
	"severity": "medium",
	"class": "Избыточные права",
	"title": "Токен сервисного аккаунта монтируется в под",
	"description": "Если приложению не нужен API Kubernetes, смонтированный токен — лишний ключ для атакующего.",
	"fix": "automount_service_account_token = false в spec пода.",
}

findings contains f if {
	some p in iac.pod_specs
	not iac.val(p.spec, "automount_service_account_token", true) == false
	f := {"address": p.address, "attr": "automount_service_account_token", "msg": "токен сервисного аккаунта монтируется автоматически"}
}
