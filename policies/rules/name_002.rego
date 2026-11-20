package rules.name_002

import rego.v1

import data.lib.iac

meta := {
	"id": "NAME-002",
	"severity": "medium",
	"class": "Именование",
	"title": "Имя пространства имён не заканчивается окружением",
	"description": "Пространство имён приложения называется <система>-<окружение>, чтобы по имени было видно, где работает код.",
	"fix": "Например: shop-dev, billing-prod.",
}

findings contains f if {
	some ns in iac.namespaces
	env := iac.labels(ns.res).environment
	is_string(env)
	is_string(ns.name)
	not contains(ns.name, "${")
	not endswith(ns.name, sprintf("-%s", [env]))
	f := {"address": ns.address, "attr": "name", "msg": sprintf("имя %q должно заканчиваться на -%s", [ns.name, env])}
}
