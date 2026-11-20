package rules.iam_006

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-006",
	"severity": "medium",
	"class": "Избыточные права",
	"title": "Контейнер может работать от root",
	"description": "Ни у пода, ни у контейнера не задан run_as_non_root = true.",
	"fix": "security_context { run_as_non_root = true, run_as_user = 10001 }.",
}

findings contains f if {
	some x in iac.containers
	not iac.val(iac.csc(x.c), "run_as_non_root", false) == true
	not iac.val(iac.podsc(x.pod), "run_as_non_root", false) == true
	f := {"address": x.address, "attr": "run_as_non_root", "msg": sprintf("контейнер %s: не запрещён запуск от root", [iac.container_name(x.c)])}
}
