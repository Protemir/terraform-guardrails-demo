package rules.iam_004

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-004",
	"severity": "high",
	"class": "Избыточные права",
	"title": "Разрешено повышение привилегий",
	"description": "Без allow_privilege_escalation = false процесс в контейнере может получить больше прав, чем у родителя (setuid).",
	"fix": "security_context { allow_privilege_escalation = false }.",
}

findings contains f if {
	some x in iac.containers
	not iac.val(iac.csc(x.c), "allow_privilege_escalation", true) == false
	f := {"address": x.address, "attr": "allow_privilege_escalation", "msg": sprintf("контейнер %s: allow_privilege_escalation не равен false", [iac.container_name(x.c)])}
}
