package rules.exc_002

import rego.v1

import data.lib.iac

meta := {
	"id": "EXC-002",
	"severity": "medium",
	"class": "Исключения",
	"title": "Просроченное исключение",
	"description": "Срок исключения истёк: оно больше не действует, нарушение снова проверяется. Запись нужно удалить или продлить с новым обоснованием.",
	"fix": "Исправьте нарушение и удалите запись или продлите expires через ревью.",
}

findings contains f if {
	some i, e in iac.exceptions
	regex.match("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", iac.expires_date(e))
	iac.expires_ns(e) < time.now_ns()
	f := {"address": sprintf("exceptions[%d]", [i]), "attr": "expires", "msg": sprintf("исключение %v для %v истекло %v", [object.get(e, "rule", "?"), object.get(e, "resource", "?"), e.expires])}
}
