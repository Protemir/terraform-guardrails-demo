package rules.res_002

import rego.v1

import data.lib.iac

meta := {
	"id": "RES-002",
	"severity": "medium",
	"class": "Ограничения ресурсов",
	"title": "Контейнер без requests",
	"description": "Без requests планировщик не знает, сколько ресурсов нужно поду, и квота пространства имён не работает.",
	"fix": "resources { requests = { cpu = \"100m\", memory = \"128Mi\" } }.",
}

findings contains f if {
	some x in iac.containers
	req := iac.obj(iac.block(x.c, "resources"), "requests")
	some k in ["cpu", "memory"]
	not req[k]
	f := {"address": x.address, "attr": "requests", "msg": sprintf("контейнер %s: не задан requests.%s", [iac.container_name(x.c), k])}
}
