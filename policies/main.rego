# Точка входа для conftest: собирает находки всех правил из data.rules.*,
# убирает действующие исключения и делит результат:
#   deny  — уровень critical, блокирует слияние;
#   warn  — high / medium / low, попадает в комментарий, но не блокирует.
package main

import rego.v1

import data.lib.iac

severities := ["critical", "high", "medium", "low"]

findings contains f if {
	some rule in data.rules
	some x in rule.findings
	m := rule.meta
	f := {
		"id": m.id,
		"severity": m.severity,
		"class": m.class,
		"title": m.title,
		"address": x.address,
		"msg": x.msg,
		"attr": object.get(x, "attr", ""),
	}
}

active contains f if {
	some f in findings
	not iac.excepted(f)
}

suppressed contains f if {
	some f in findings
	iac.excepted(f)
}

deny contains r if {
	some f in active
	f.severity == "critical"
	r := report(f)
}

warn contains r if {
	some f in active
	f.severity != "critical"
	r := report(f)
}

# Нарушения, снятые действующим исключением, тоже попадают в отчёт — с пометкой excepted,
# чтобы в комментарии было видно, какое правило и почему не сработало.
warn contains r if {
	some f in suppressed
	r := object.union(report(f), {
		"msg": sprintf("[%s] %s — снято исключением: %s", [f.id, f.address, f.msg]),
		"excepted": true,
		"original_severity": f.severity,
		"severity": "info",
	})
}

report(f) := {
	"msg": sprintf("[%s] %s — %s", [f.id, f.address, f.msg]),
	"rule": f.id,
	"severity": f.severity,
	"class": f.class,
	"title": f.title,
	"address": f.address,
	"attr": f.attr,
}
