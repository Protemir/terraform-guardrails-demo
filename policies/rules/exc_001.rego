package rules.exc_001

import rego.v1

import data.lib.iac

meta := {
	"id": "EXC-001",
	"severity": "critical",
	"class": "Исключения",
	"title": "Исключение оформлено без обоснования, владельца или срока",
	"description": "Каждое исключение в policies/exceptions.yaml содержит правило, ресурс, обоснование (от 15 символов), владельца и дату окончания не дальше 180 дней. Иначе оно не действует и само блокирует слияние.",
	"fix": "Дополните запись: reason, owner, expires: YYYY-MM-DD.",
}

problems := [
	"нет обоснования (reason от 15 символов)",
	"нет владельца (owner)",
	"нет поля rule или resource",
	"нет срока (expires)",
	"срок дальше 180 дней",
]

findings contains f if {
	some i, e in iac.exceptions
	some problem in problems
	problem_of(e, problem)
	f := {"address": sprintf("exceptions[%d]", [i]), "attr": "exceptions", "msg": sprintf("исключение %v для %v: %s", [object.get(e, "rule", "?"), object.get(e, "resource", "?"), problem])}
}

problem_of(e, "нет обоснования (reason от 15 символов)") if count(trim_space(object.get(e, "reason", ""))) < 15

problem_of(e, "нет владельца (owner)") if object.get(e, "owner", "") == ""

problem_of(e, "нет поля rule или resource") if {
	some k in ["rule", "resource"]
	object.get(e, k, "") == ""
}

problem_of(e, "нет срока (expires)") if not regex.match("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", iac.expires_date(e))

problem_of(e, "срок дальше 180 дней") if {
	regex.match("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", iac.expires_date(e))
	iac.expires_ns(e) - time.now_ns() > ((180 * 24) * 3600) * 1000000000
}
