package rules.iam_007

import rego.v1

import data.lib.iac

meta := {
	"id": "IAM-007",
	"severity": "medium",
	"class": "Избыточные права",
	"title": "Корневая файловая система контейнера доступна на запись",
	"description": "Без read_only_root_filesystem атакующий может менять бинарники внутри контейнера.",
	"fix": "security_context { read_only_root_filesystem = true }, временные файлы — в emptyDir.",
}

findings contains f if {
	some x in iac.containers
	not iac.val(iac.csc(x.c), "read_only_root_filesystem", false) == true
	f := {"address": x.address, "attr": "read_only_root_filesystem", "msg": sprintf("контейнер %s: корневая ФС доступна на запись", [iac.container_name(x.c)])}
}
