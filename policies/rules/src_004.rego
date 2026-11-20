package rules.src_004

import rego.v1

import data.lib.iac

meta := {
	"id": "SRC-004",
	"severity": "high",
	"class": "Версии и источники модулей",
	"title": "Чарт Helm без закреплённой версии",
	"description": "Без точной version helm_release ставит последнюю версию чарта на момент применения: результат зависит от дня запуска.",
	"fix": "version = \"42.4.1\".",
}

findings contains f if {
	some r in iac.of_type("helm_release")
	remote(r.values)
	v := iac.val(r.values, "version", "")
	not contains(v, "${")
	not exact(v)
	f := {"address": r.address, "attr": "version", "msg": sprintf("чарт %v: version %q — нужна точная версия", [iac.val(r.values, "chart", "?"), v])}
}

remote(v) if iac.val(v, "repository", "") != ""

remote(v) if startswith(iac.val(v, "chart", ""), "oci://")

exact(v) if regex.match("^v?[0-9]+[.][0-9]+[.][0-9]+([-+][0-9A-Za-z.-]+)?$", v)
