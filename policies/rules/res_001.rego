package rules.res_001

import rego.v1

import data.lib.iac

meta := {
	"id": "RES-001",
	"severity": "high",
	"class": "Ограничения ресурсов",
	"title": "Контейнер без лимитов CPU и памяти",
	"description": "Контейнер без limits может занять весь узел и уронить соседние приложения.",
	"fix": "resources { limits = { cpu = \"500m\", memory = \"256Mi\" } }.",
}

findings contains f if {
	some x in iac.containers
	res := iac.block(x.c, "resources")
	limits := iac.obj(res, "limits")
	some k in ["cpu", "memory"]
	not limits[k]
	f := {"address": x.address, "attr": "limits", "msg": sprintf("контейнер %s: не задан limits.%s", [iac.container_name(x.c), k])}
}
