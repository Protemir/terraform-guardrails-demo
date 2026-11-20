package rules.res_006

import rego.v1

import data.lib.iac

meta := {
	"id": "RES-006",
	"severity": "medium",
	"class": "Ограничения ресурсов",
	"title": "Долгоживущий контейнер без проверок готовности и живости",
	"description": "Без readiness_probe трафик идёт на неготовый под, без liveness_probe зависший процесс не перезапускается.",
	"fix": "Добавьте readiness_probe и liveness_probe.",
}

long_running := {
	"kubernetes_deployment_v1", "kubernetes_deployment",
	"kubernetes_stateful_set_v1", "kubernetes_stateful_set",
	"kubernetes_daemon_set_v1", "kubernetes_daemonset",
}

findings contains f if {
	some x in iac.containers
	x.kind == "container"
	some p in iac.pod_specs
	p.address == x.address
	p.res.type in long_running
	some probe in ["readiness_probe", "liveness_probe"]
	count(iac.arr(x.c, probe)) == 0
	f := {"address": x.address, "attr": probe, "msg": sprintf("контейнер %s: нет %s", [iac.container_name(x.c), probe])}
}
