package rules.pub_003

import rego.v1

import data.lib.iac

meta := {
	"id": "PUB-003",
	"severity": "critical",
	"class": "Публичный доступ",
	"title": "Под в сетевом или процессном пространстве узла",
	"description": "host_network, host_pid, host_ipc или host_port дают поду прямой доступ к сети и процессам узла и выводят его из-под сетевых политик.",
	"fix": "Уберите host_network / host_pid / host_ipc и host_port; публикуйте порт через Service.",
}

findings contains f if {
	some p in iac.pod_specs
	some attr in ["host_network", "host_pid", "host_ipc"]
	iac.val(p.spec, attr, false) == true
	f := {"address": p.address, "attr": attr, "msg": sprintf("%s = true", [attr])}
}

findings contains f if {
	some x in iac.containers
	some port in iac.arr(x.c, "port")
	iac.val(port, "host_port", 0) > 0
	f := {"address": x.address, "attr": "host_port", "msg": sprintf("контейнер %s занимает host_port %v", [iac.container_name(x.c), port.host_port])}
}
