package rules.iam_003

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-003",
	"severity": "critical",
	"class": "Избыточные права",
	"title": "Привилегированный контейнер",
	"description": "privileged = true даёт контейнеру права root на узле.",
	"fix": "Уберите privileged; нужные права выдайте точечно через capabilities.",
}

findings contains f if {
	some x in iac.containers
	iac.val(iac.csc(x.c), "privileged", false) == true
	f := {"address": x.address, "attr": "privileged", "msg": sprintf("контейнер %s запущен с privileged = true", [iac.container_name(x.c)])}
}
